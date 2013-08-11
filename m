From: Amir Vadai <amirv.mellanox@gmail.com>
Subject: Re: mlx4 interrupt coalescing not important for small packets?
Date: Sun, 11 Aug 2013 16:23:31 +0300
Message-ID: <52079053.5070405@gmail.com>
References: <20130809170637.GA5258@sbohrermbp13-local.rgmadvisors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Amir Vadai <amirv@mellanox.com>
To: Shawn Bohrer <shawn.bohrer@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f178.google.com ([209.85.215.178]:47677 "EHLO
	mail-ea0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753459Ab3HKNXe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Aug 2013 09:23:34 -0400
Received: by mail-ea0-f178.google.com with SMTP id a15so2867818eae.23
        for <netdev@vger.kernel.org>; Sun, 11 Aug 2013 06:23:33 -0700 (PDT)
In-Reply-To: <20130809170637.GA5258@sbohrermbp13-local.rgmadvisors.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/08/2013 20:06, Shawn Bohrer wrote:
> I was looking at the adaptive interrupt coalescing algorithm for
> mlx4_en which contains the following snippet:
> 
> /* Apply auto-moderation only when packet rate
>  * exceeds a rate that it matters */
> if (rate > (MLX4_EN_RX_RATE_THRESH / priv->rx_ring_num) &&
>     avg_pkt_size > MLX4_EN_AVG_PKT_SMALL) {
>         if (rate < priv->pkt_rate_low)
>                 moder_time = priv->rx_usecs_low;
>         else if (rate > priv->pkt_rate_high)
>                 moder_time = priv->rx_usecs_high;
>         else
>                 moder_time = (rate - priv->pkt_rate_low) *
>                         (priv->rx_usecs_high - priv->rx_usecs_low) /
>                         (priv->pkt_rate_high - priv->pkt_rate_low) +
>                         priv->rx_usecs_low;
> } else {
>         moder_time = priv->rx_usecs_low;
> }
> 
> In this case MLX4_EN_AVG_PKT_SMALL is 256 bytes.  Can someone explain
> to me why interrupt coalescing is not important for small packets
> regardless of the incoming packet rate?
> 
> Thanks,
> Shawn
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

The idea was that for small packets, should enter "latency mode"
regardless the packet rate.

Amir
