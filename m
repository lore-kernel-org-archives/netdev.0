From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] Arp announce (for Xen)
Date: Mon, 05 Mar 2007 20:35:36 -0800 (PST)
Message-ID: <20070305.203536.92584097.davem@davemloft.net>
References: <20070301164214.4a40bc59@freekitty>
	<45E7764A.7000100@goop.org>
	<20070301173030.754514ec@freekitty>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeremy@goop.org, ak@muc.de, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, virtualization@lists.osdl.org,
	xen-devel@lists.xensource.com, chrisw@sous-sol.org,
	zach@vmware.com, rusty@rustcorp.com.au, ian.pratt@xensource.com,
	Christian.Limpach@cl.cam.ac.uk, netdev@vger.kernel.org,
	jeff@garzik.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49495
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752163AbXCFEfl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2007 23:35:41 -0500
In-Reply-To: <20070301173030.754514ec@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Thu, 1 Mar 2007 17:30:30 -0800

> What about implementing the unused arp_announce flag on the inetdevice?
> Something like the following.  Totally untested...
> 
> Looks like it either was there (and got removed) or was planned but
> never implemented.

This idea is fine.  But:

> +	case NETDEV_CHANGEADDR:
> +		/* Send gratuitous ARP in case of address change or new device */
> +		if (IN_DEV_ARP_ANNOUNCE(in_dev))
> +			arp_send(ARPOP_REQUEST, ETH_P_ARP,
> +				 in_dev->ifa_list->ifa_address, dev,
> +				 in_dev->ifa_list->ifa_address, NULL, 
> +				 dev->dev_addr, NULL);

We'll need to make sure the appropriate 'arp_anounce' address
selection is employed here.

One idea is to change arp_solicit() such that it can be invoked in
this context, or provide a new helper function which will do the
source address selection rules of 'arp_announce' and then invoke
arp_send() as appropriate for us.
