From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH] net: Add etun driver
Date: Fri, 06 Apr 2007 13:57:25 -0700
Message-ID: <adak5wp6x1m.fsf@cisco.com>
References: <m1abxl5j4s.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Ben Greear <greearb@candelatech.com>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Dmitry Mishin <dim@openvz.org>,
	Linux Containers <containers@lists.osdl.org>
To: ebiederm@xmission.com (Eric W. Biederman)
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:7582 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932950AbXDFU5k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Apr 2007 16:57:40 -0400
In-Reply-To: <m1abxl5j4s.fsf@ebiederm.dsl.xmission.com> (Eric W. Biederman's message of "Fri, 06 Apr 2007 14:43:15 -0600")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > +/*
 > + * The higher levels take care of making this non-reentrant (it's
 > + * called with bh's disabled).
 > + */
 > +static int etun_xmit(struct sk_buff *skb, struct net_device *tx_dev)

You have this comment, but then...

 > +	dev->features		= NETIF_F_FRAGLIST
 > +				  | NETIF_F_HIGHDMA
 > +				  | NETIF_F_LLTX;

you set LLTX, which means that the upper layers _don't_ make sure that
your xmit routine is not reentrant.

It looks like the impact of multiple simultaneous xmit calls is just
the possibility of screwing up the statistics, but still I think you
want to drop the LLTX feature (since you have no lock of your own to
try and take).
