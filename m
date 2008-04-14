From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 3/5] e1000e: Allow TSO to trickle down to VLAN device
Date: Mon, 14 Apr 2008 19:11:23 +0200
Message-ID: <4803903B.1020100@trash.net>
References: <20080414170557.23286.71580.stgit@localhost.localdomain> <20080414170609.23286.42880.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:46507 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760042AbYDNROi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 13:14:38 -0400
In-Reply-To: <20080414170609.23286.42880.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Auke Kok wrote:
> Fix TSO over VLAN's by propagating settings to our VLAN devices.
>   

> @@ -378,8 +381,21 @@ static int e1000_set_tso(struct net_device *netdev, u32 data)
>  	} else {
>  		netdev->features &= ~NETIF_F_TSO;
>  		netdev->features &= ~NETIF_F_TSO6;
> +		/* disable TSO on all VLANs if they're present */
> +		if (!adapter->vlgrp)
> +			goto tso_out;
> +		for (i = 0; i < VLAN_GROUP_ARRAY_LEN; i++) {
> +			v_netdev = vlan_group_get_device(adapter->vlgrp, i);
> +			if (!v_netdev)
> +				continue;
> +
> +			v_netdev->features &= ~NETIF_F_TSO;
> +			v_netdev->features &= ~NETIF_F_TSO6;
> +			vlan_group_set_device(adapter->vlgrp, i, v_netdev);
>   

What exactly is this supposed to fix? If this simply wants
to propagate feature changes, I think it should use
netdev_feat_change and handle that within the VLAN code.


