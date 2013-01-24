From: Jamie Gloudon <jamie.gloudon@gmail.com>
Subject: Re: [PATCH net-next] via-rhine: add 64bit statistics.
Date: Wed, 23 Jan 2013 20:20:52 -0400
Message-ID: <51007e6c.4170ec0a.7218.18c2@mx.google.com>
References: <50fff42d.094e640a.3ace.6ae4@mx.google.com>
 <1358951884.12374.790.camel@edumazet-glaptop>
 <510004a3.2444ec0a.1ba7.ffff98b3@mx.google.com>
 <1358957838.12374.805.camel@edumazet-glaptop>
 <5100786f.04bc650a.65b3.fffffd3d@mx.google.com>
 <1358985772.12374.1250.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f53.google.com ([209.85.213.53]:45246 "EHLO
	mail-yh0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752486Ab3AXAVB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 19:21:01 -0500
Received: by mail-yh0-f53.google.com with SMTP id q3so350011yhf.12
        for <netdev@vger.kernel.org>; Wed, 23 Jan 2013 16:21:01 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1358985772.12374.1250.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 23, 2013 at 04:02:52PM -0800, Eric Dumazet wrote:
> On Wed, 2013-01-23 at 19:55 -0400, Jamie Gloudon wrote:
> 
> > Eric, do you mean like this below? If not, please illustrate.
> > 
> > +       netdev_stats_to_stats64(stats, &dev->stats);
> > +
> > +       do {
> > +               start = u64_stats_fetch_begin_bh(&rp->rx_stats.syncp);
> > +               stats->rx_packets = rp->rx_stats.packets;
> > +               stats->rx_bytes = rp->rx_stats.bytes;
> > +       } while (u64_stats_fetch_retry_bh(&rp->rx_stats.syncp, start));
> > +
> > +       do {
> > +               start = u64_stats_fetch_begin_bh(&rp->tx_stats.syncp);
> > +               stats->tx_packets = rp->tx_stats.packets;
> > +               stats->tx_bytes = rp->tx_stats.bytes;
> > +       } while (u64_stats_fetch_retry_bh(&rp->tx_stats.syncp, start));
> > +
> > +       return stats;
> > 
> 
> Yes, this is exactly how you should do that, since
> netdev_stats_to_stats64(stats, &dev->stats); would overwrite
> {tr}x_packets, {tr}x_bytes anyway.
> 
>

Right. Also, I added rx_dropped to increment for oversize ethernet. Is
that valid?

@@ -1857,6 +1869,7 @@ static int rhine_rx(struct net_device *dev, int
limit)
	"Oversized Ethernet frame %p vs %p\n", rp->rx_head_desc,                        	&rp->rx_ring[entry]);
+	dev->stats.rx_dropped++;
	dev->stats.rx_length_errors++;
