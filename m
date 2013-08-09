From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] gianfar: add support for LFC (Lossless Flow Control)
Date: Fri, 09 Aug 2013 01:39:06 -0700
Message-ID: <1376037546.2087.69.camel@joe-AO722>
References: <1375987549.2853.67.camel@deadeye.wl.decadent.org.uk>
	 <1376036790-18238-1-git-send-email-ljaenicke@innominate.com>
	 <1376036790-18238-3-git-send-email-ljaenicke@innominate.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Claudiu Manoil <claudiu.manoil@freescale.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	"David S. Miller" <davem@davemloft.net>
To: Lutz Jaenicke <ljaenicke@innominate.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:46913 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1030590Ab3HIIjI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Aug 2013 04:39:08 -0400
In-Reply-To: <1376036790-18238-3-git-send-email-ljaenicke@innominate.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-08-09 at 10:26 +0200, Lutz Jaenicke wrote:
> Implement Lossless Flow Control (let the MAC automatically generate
> PAUSE frames in case of too much incoming traffic.
> Selection of this feature is performed via device tree parameter.
> The board (and processor) specific device tree is authoritative wrt this
> information.

Just a trivial note:

> diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
[]
> @@ -169,10 +169,12 @@ static void gfar_init_rxbdp(struct gfar_priv_rx_q *rx_queue, struct rxbd8 *bdp,
[]
> +	u32 *rfbptr;
[]
> @@ -222,6 +225,11 @@ static int gfar_init_bds(struct net_device *ndev)
[]
> +		if (priv->device_flags & FSL_GIANFAR_DEV_HAS_LFC)
> +			rx_queue->rfbptr = rfbptr;
> +		else
> +			rx_queue->rfbptr = 0;

s/0/NULL/
