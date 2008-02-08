From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [patch 1/2] qeth: new qeth device driver
Date: Fri, 8 Feb 2008 07:54:16 -0800
Message-ID: <20080208155416.GB12085@linux.vnet.ibm.com>
References: <20080208140959.259912000@de.ibm.com> <20080208141535.271607000@de.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: Frank.Blaschka@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:59001 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751520AbYBHPyd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2008 10:54:33 -0500
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m18FsM1X030905
	for <netdev@vger.kernel.org>; Fri, 8 Feb 2008 10:54:22 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m18FsK2Q099850
	for <netdev@vger.kernel.org>; Fri, 8 Feb 2008 08:54:20 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m18FsJ40028598
	for <netdev@vger.kernel.org>; Fri, 8 Feb 2008 08:54:20 -0700
Content-Disposition: inline
In-Reply-To: <20080208141535.271607000@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 08, 2008 at 03:10:00PM +0100, Frank.Blaschka@de.ibm.com wrote:
> From: Frank Blaschka <frank.blaschka@de.ibm.com>
> 
> List of major changes and improvements:
>  no manipulation of the global ARP constructor
>  clean code split into core, layer 2 and layer 3 functionality
>  better exploitation of the ethtool interface
>  better representation of the various hardware capabilities
>  fix packet socket support (tcpdump), no fake_ll required
>  osasnmpd notification via udev events
>  coding style and beautification

One question below...

> Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
> ---

[ . . . ]

> +static void qeth_l3_vlan_rx_add_vid(struct net_device *dev, unsigned short vid)
> +{
> +	struct net_device *vlandev;
> +	struct qeth_card *card = (struct qeth_card *) dev->priv;
> +	struct in_device *in_dev;
> +
> +	if (card->info.type == QETH_CARD_TYPE_IQD)
> +		return;
> +
> +	vlandev = vlan_group_get_device(card->vlangrp, vid);
> +	vlandev->neigh_setup = qeth_l3_neigh_setup;
> +
> +	in_dev = __in_dev_get_rcu(vlandev);

Is this really in an RCU read-side critical section?  Or is this just
using common code?

						Thanx, Paul
