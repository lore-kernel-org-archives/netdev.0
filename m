From: Shawn Bohrer <shawn.bohrer@gmail.com>
Subject: mlx4 interrupt coalescing not important for small packets?
Date: Fri, 9 Aug 2013 12:06:37 -0500
Message-ID: <20130809170637.GA5258@sbohrermbp13-local.rgmadvisors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Amir Vadai <amirv@mellanox.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f182.google.com ([209.85.214.182]:53727 "EHLO
	mail-ob0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751569Ab3HIRGx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Aug 2013 13:06:53 -0400
Received: by mail-ob0-f182.google.com with SMTP id wo10so6705844obc.13
        for <netdev@vger.kernel.org>; Fri, 09 Aug 2013 10:06:52 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I was looking at the adaptive interrupt coalescing algorithm for
mlx4_en which contains the following snippet:

/* Apply auto-moderation only when packet rate
 * exceeds a rate that it matters */
if (rate > (MLX4_EN_RX_RATE_THRESH / priv->rx_ring_num) &&
    avg_pkt_size > MLX4_EN_AVG_PKT_SMALL) {
        if (rate < priv->pkt_rate_low)
                moder_time = priv->rx_usecs_low;
        else if (rate > priv->pkt_rate_high)
                moder_time = priv->rx_usecs_high;
        else
                moder_time = (rate - priv->pkt_rate_low) *
                        (priv->rx_usecs_high - priv->rx_usecs_low) /
                        (priv->pkt_rate_high - priv->pkt_rate_low) +
                        priv->rx_usecs_low;
} else {
        moder_time = priv->rx_usecs_low;
}

In this case MLX4_EN_AVG_PKT_SMALL is 256 bytes.  Can someone explain
to me why interrupt coalescing is not important for small packets
regardless of the incoming packet rate?

Thanks,
Shawn
