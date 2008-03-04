From: Pekka Pietikainen <pp@ee.oulu.fi>
Subject: Re: capturing vlan on 2.6.18
Date: Tue, 4 Mar 2008 13:18:32 +0200
Message-ID: <20080304111832.GA20494@ee.oulu.fi>
References: <200802281226.08987.krauz@cncz.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Pavel Krauz <krauz@cncz.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ee.oulu.fi ([130.231.61.23]:37813 "EHLO ee.oulu.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754218AbYCDLSv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Mar 2008 06:18:51 -0500
Content-Disposition: inline
In-Reply-To: <200802281226.08987.krauz@cncz.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 28, 2008 at 12:26:08PM +0100, Pavel Krauz wrote:
> >> Is this a kernel bug or am I supposed to set something?
> > It's an unfortunate side effect of hardware VLAN acceleration. It
> > can't be turned off (apart from patching the driver to not advertise
> > VLAN acceleration support).
> I think that enabling VLAN tags shall be at least kernel run-time or boot time
>  configurable option.
> 
> For a test I have tried to enable VLAN tags in the Broadcom NX2 network driver (drivers/net/bnx2.c)
> and I got the VLAN back. Can you tell me if this is the correct way:
> 
> --- bnx2.c.bak  2008-02-28 11:47:29.000000000 +0100
> +++ bnx2.c      2008-02-28 11:47:43.000000000 +0100
> @@ -2039,6 +2039,7 @@
>  #endif
>         if (dev->flags & IFF_PROMISC) {
>                 /* Promiscuous mode. */
> +               rx_mode |= BNX2_EMAC_RX_MODE_KEEP_VLAN_TAG;
>                 rx_mode |= BNX2_EMAC_RX_MODE_PROMISCUOUS;
>                 sort_mode |= BNX2_RPM_SORT_USER0_PROM_EN;
>         }
> 
Oh, the no VLAN tags with bnx2 is a slightly different matter,
I've used the patch

#ifdef BCM_VLAN
        if (!bp->vlgrp && !(bp->flags & ASF_ENABLE_FLAG))
                rx_mode |= BNX2_EMAC_RX_MODE_KEEP_VLAN_TAG;
#else

->
        if (!bp->vlgrp) // && !(bp->flags & ASF_ENABLE_FLAG))
                rx_mode |= BNX2_EMAC_RX_MODE_KEEP_VLAN_TAG;

Apparently there's a DOS tool that can be used to disable the ASF bit
(It's some enterprise management thing that I haven't ever figured out what
it's even useful for) permanently, 
http://www.broadcom.com/support/ethernet_nic/netxtremeii.php

Since I need lots of ports on my monitoring boxes anyway, I just use
external dual-port e1000's for monitoring and use the on-board bnx2 for
managment. Much easier :-)
