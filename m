From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [RFC PATCH v2 1/2] macb: Add 1588 support in Cadence GEM.
Date: Sun, 20 Nov 2016 20:37:20 +0100
Message-ID: <20161120193720.GA7874@localhost.localdomain>
References: <1479478912-14067-1-git-send-email-andrei.pistirica@microchip.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, davem@davemloft.net,
        nicolas.ferre@atmel.com, harinikatakamlinux@gmail.com,
        harini.katakam@xilinx.com, punnaia@xilinx.com, michals@xilinx.com,
        anirudh@xilinx.com, boris.brezillon@free-electrons.com,
        alexandre.belloni@free-electrons.com, tbultel@pixelsurmer.com
To: Andrei Pistirica <andrei.pistirica@microchip.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36789 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752857AbcKTTh1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 20 Nov 2016 14:37:27 -0500
Content-Disposition: inline
In-Reply-To: <1479478912-14067-1-git-send-email-andrei.pistirica@microchip.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 18, 2016 at 03:21:51PM +0100, Andrei Pistirica wrote:
> +#ifdef CONFIG_MACB_USE_HWSTAMP
> +void macb_ptp_init(struct net_device *ndev);
> +#else
> +void macb_ptp_init(struct net_device *ndev) { }

static inline ^^^

> +#endif


> +void macb_ptp_init(struct net_device *ndev)
> +{
> +	struct macb *bp = netdev_priv(ndev);
> +	struct timespec64 now;
> +	u32 rem = 0;
> +
> +	if (!(bp->caps | MACB_CAPS_GEM_HAS_PTP)){
> +		netdev_vdbg(bp->dev, "Platform does not support PTP!\n");
> +		return;
> +	}

You would have needed '&' and not '|' here.

Also, using a flag limits the code to your platform.  This works for
you, but it is short sighted.  The other MACB PTP blocks have
different register layouts, and this patch does not lay the ground
work for the others.

The driver needs to be designed to support the other platforms.

Thanks,
Richard
