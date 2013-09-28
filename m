From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] can: add Renesas R-Car CAN driver
Date: Fri, 27 Sep 2013 17:45:18 -0700
Message-ID: <20130927174518.2ee83214@nehalam.linuxnetplumber.net>
References: <201309280211.39068.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wg@grandegger.com, mkl@pengutronix.de,
	linux-can@vger.kernel.org, linux-sh@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:47841 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753625Ab3I1ApX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Sep 2013 20:45:23 -0400
Received: by mail-pb0-f41.google.com with SMTP id rp2so3229580pbb.0
        for <netdev@vger.kernel.org>; Fri, 27 Sep 2013 17:45:22 -0700 (PDT)
In-Reply-To: <201309280211.39068.sergei.shtylyov@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 28 Sep 2013 02:11:38 +0400
Sergei Shtylyov <sergei.shtylyov@cogentembedded.com> wrote:

> +	stats->rx_bytes += cf->can_dlc;
> +}
> +
> +static irqreturn_t rcar_can_interrupt(int irq, void *dev_id)
> +{
> +	struct net_device *ndev = (struct net_device *)dev_id;
> +	struct rcar_can_priv *priv = netdev_priv(ndev);
> +	struct net_device_stats *stats = &ndev->stats;
> +	u8 isr;
> +
> +	isr = rcar_can_readb(priv, RCAR_CAN_ISR);
> +	if (isr & ISR_ERSF)
> +		rcar_can_error(ndev);

IRQ handler should return IRQ_NONE if not for this device.
Most devices this is true if isr is 0.
Also should check for hot-plug case where device interrupt occurs
but see's all-ones on the bus.
