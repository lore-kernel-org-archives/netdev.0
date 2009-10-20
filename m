From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] can: provide library functions for skb allocation
Date: Mon, 19 Oct 2009 21:54:40 -0700 (PDT)
Message-ID: <20091019.215440.256002623.davem@davemloft.net>
References: <4ADB6243.2040109@grandegger.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, socketcan-core@lists.berlios.de,
	haas@ems-wuensche.com, anantgole@ti.com, mkl@pengutronix.de
To: wg@grandegger.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40955
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751186AbZJTEyS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2009 00:54:18 -0400
In-Reply-To: <4ADB6243.2040109@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wolfgang Grandegger <wg@grandegger.com>
Date: Sun, 18 Oct 2009 20:45:23 +0200

> This patch makes the private functions alloc_can_skb() and
> alloc_can_err_skb() of the at91_can driver public and adapts all
> drivers to use these. While making the patch I realized, that
> the skb's are *not* setup consistently. It's now done as shown
> below:
> 
>   skb->protocol = htons(ETH_P_CAN);
>   skb->pkt_type = PACKET_BROADCAST;
>   skb->ip_summed = CHECKSUM_UNNECESSARY;
>   *cf = (struct can_frame *)skb_put(skb, sizeof(struct can_frame));
>   memset(*cf, 0, sizeof(struct can_frame));
> 
> The frame is zeroed out to avoid uninitialized data to be passed to
> user space. Some drivers or library code did not set "pkt_type" or 
> "ip_summed". Also,  "__constant_htons()" should not be used for
> runtime invocations, as pointed out by David Miller.
> 
> Signed-off-by: Wolfgang Grandegger <wg@grandegger.com>

Applied, thanks.
