From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] via-rhine: add 64bit statistics.
Date: Wed, 23 Jan 2013 16:02:52 -0800
Message-ID: <1358985772.12374.1250.camel@edumazet-glaptop>
References: <50fff42d.094e640a.3ace.6ae4@mx.google.com>
	 <1358951884.12374.790.camel@edumazet-glaptop>
	 <510004a3.2444ec0a.1ba7.ffff98b3@mx.google.com>
	 <1358957838.12374.805.camel@edumazet-glaptop>
	 <5100786f.04bc650a.65b3.fffffd3d@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Jamie Gloudon <jamie.gloudon@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:58531 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751812Ab3AXACy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 19:02:54 -0500
Received: by mail-pb0-f42.google.com with SMTP id rp2so5043459pbb.1
        for <netdev@vger.kernel.org>; Wed, 23 Jan 2013 16:02:54 -0800 (PST)
In-Reply-To: <5100786f.04bc650a.65b3.fffffd3d@mx.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-01-23 at 19:55 -0400, Jamie Gloudon wrote:

> Eric, do you mean like this below? If not, please illustrate.
> 
> +       netdev_stats_to_stats64(stats, &dev->stats);
> +
> +       do {
> +               start = u64_stats_fetch_begin_bh(&rp->rx_stats.syncp);
> +               stats->rx_packets = rp->rx_stats.packets;
> +               stats->rx_bytes = rp->rx_stats.bytes;
> +       } while (u64_stats_fetch_retry_bh(&rp->rx_stats.syncp, start));
> +
> +       do {
> +               start = u64_stats_fetch_begin_bh(&rp->tx_stats.syncp);
> +               stats->tx_packets = rp->tx_stats.packets;
> +               stats->tx_bytes = rp->tx_stats.bytes;
> +       } while (u64_stats_fetch_retry_bh(&rp->tx_stats.syncp, start));
> +
> +       return stats;
> 

Yes, this is exactly how you should do that, since
netdev_stats_to_stats64(stats, &dev->stats); would overwrite
{tr}x_packets, {tr}x_bytes anyway.
