From: "Sebastian =?ISO-8859-1?Q?P=F6hn?=" <sebastian.belden@googlemail.com>
Subject: Re: [PATCH] gianfar: fix bug caused by
 87c288c6e9aa31720b72e2bc2d665e24e1653c3e
Date: Tue, 26 Jul 2011 13:13:41 +0200
Message-ID: <1311678821.17939.7.camel@DENEC1DT0191>
References: <1311674593.17190.7.camel@DENEC1DT0191>
	 <20110726104559.GA2078@minipsycho.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jiri Pirko <jpirko@redhat.com>,
	Linux Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:53245 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751211Ab1GZLNq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jul 2011 07:13:46 -0400
Received: by wyg8 with SMTP id 8so92348wyg.19
        for <netdev@vger.kernel.org>; Tue, 26 Jul 2011 04:13:45 -0700 (PDT)
In-Reply-To: <20110726104559.GA2078@minipsycho.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Dienstag, den 26.07.2011, 12:46 +0200 schrieb Jiri Pirko:
> Tue, Jul 26, 2011 at 12:03:13PM CEST, sebastian.belden@googlemail.com wrote:
> >commit 87c288c6e9aa31720b72e2bc2d665e24e1653c3e "gianfar: do vlan cleanup" has two issues:
> ># permutation of rx and tx flags
> ># enabling vlan tag insertion by default (this leads to unusable connections on some configurations)
> 
> How so? What's causing that?
If you enable the VLINS bit of txctrl and do not alter the vlan tag
configuration of the NIC, every packet will get a all zero vlan tag
(0x8100 0000). If you run a network without vlan awareness all packets
will be ignored.

In my configuration gianfar system <-> 3c59x system the 3com system
discards all packets received with the vlan tag.
> 
> >
> >If VLAN insertion is requested (via ethtool) it will be set at an other point ...
> >
> >Signed-off-by: Sebastian Poehn <sebastian.poehn@belden.com>
> >---
> >
> > drivers/net/gianfar.c |    6 +-----
> > 1 files changed, 1 insertions(+), 5 deletions(-)
> >
> >diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
> >index 835cd25..2659daa 100644
> >--- a/drivers/net/gianfar.c
> >+++ b/drivers/net/gianfar.c
> >@@ -388,12 +388,8 @@ static void gfar_init_mac(struct net_device *ndev)
> > 	if (priv->hwts_rx_en)
> > 		rctrl |= RCTRL_PRSDEP_INIT | RCTRL_TS_ENABLE;
> > 
> >-	/* keep vlan related bits if it's enabled */
> >-	if (ndev->features & NETIF_F_HW_VLAN_TX)
> >-		rctrl |= RCTRL_VLEX | RCTRL_PRSDEP_INIT;
> >-
> > 	if (ndev->features & NETIF_F_HW_VLAN_RX)
> >-		tctrl |= TCTRL_VLINS;
> >+		rctrl |= RCTRL_VLEX | RCTRL_PRSDEP_INIT;
> > 
> > 	/* Init rctrl based on our settings */
> > 	gfar_write(&regs->rctrl, rctrl);
> >
> >
> 
> If you really need that to be done, you should remove NETIF_F_HW_VLAN_TX
> from features (not hw_features) (never add it).
> 
The only thing I did is to let the vlan insertion disabled by default.
If someone wants it, it may be enabled via ethtool.


