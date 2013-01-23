From: Jamie Gloudon <jamie.gloudon@gmail.com>
Subject: Re: [PATCH net-next] via-rhine: add 64bit statistics.
Date: Wed, 23 Jan 2013 19:55:19 -0400
Message-ID: <5100786f.04bc650a.65b3.fffffd3d@mx.google.com>
References: <50fff42d.094e640a.3ace.6ae4@mx.google.com>
 <1358951884.12374.790.camel@edumazet-glaptop>
 <510004a3.2444ec0a.1ba7.ffff98b3@mx.google.com>
 <1358957838.12374.805.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f178.google.com ([209.85.161.178]:51650 "EHLO
	mail-gg0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751127Ab3AXABD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 19:01:03 -0500
Received: by mail-gg0-f178.google.com with SMTP id 21so338505ggh.23
        for <netdev@vger.kernel.org>; Wed, 23 Jan 2013 16:01:01 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1358957838.12374.805.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 23, 2013 at 08:17:18AM -0800, Eric Dumazet wrote:
> On Wed, 2013-01-23 at 11:41 -0400, Jamie Gloudon wrote:
> > On Wed, Jan 23, 2013 at 06:38:04AM -0800, Eric Dumazet wrote:
> > > On Wed, 2013-01-23 at 10:31 -0400, Jamie Gloudon wrote:
> > > > Switch to use ndo_get_stats64 to get 64bit statistics.
> > > > 
> > > > Signed-off-by: Jamie Gloudon <jamie.gloudon@gmail.com>
> > > > ---
> > > 
> > > > +
> > > > +	stats->rx_errors = dev->stats.rx_errors;
> > > > +	stats->tx_errors = dev->stats.tx_errors;
> > > > +	stats->rx_dropped = dev->stats.rx_dropped;
> > > > +	stats->tx_dropped = dev->stats.tx_dropped;
> > > > +	stats->collisions = dev->stats.collisions;
> > > > +
> > > > +	stats->rx_length_errors = dev->stats.rx_length_errors;
> > > > +	stats->rx_crc_errors = dev->stats.rx_crc_errors;
> > > > +	stats->rx_frame_errors = dev->stats.rx_frame_errors;
> > > > +	stats->rx_fifo_errors = dev->stats.rx_fifo_errors;
> > > > +	stats->rx_missed_errors = dev->stats.rx_missed_errors;
> > > > +
> > > > +	stats->tx_aborted_errors = dev->stats.tx_aborted_errors;
> > > > +	stats->tx_carrier_errors = dev->stats.tx_carrier_errors;
> > > > +	stats->tx_fifo_errors = dev->stats.tx_fifo_errors;
> > > > +	stats->tx_heartbeat_errors = dev->stats.tx_heartbeat_errors;
> > > > +	stats->tx_window_errors = dev->stats.tx_window_errors;
> > > > +
> > > > +	return stats;
> > > >  }
> > > >  
> > > 
> > > Hi Jamie
> > > 
> > > Please use netdev_stats_to_stats64() for this block
> > > 
> > > commit 77a1abf54f4b003ad6e59c535045b2ad89fedfeb
> > > Author: Eric Dumazet <eric.dumazet@gmail.com>
> > > Date:   Mon Mar 5 04:50:09 2012 +0000
> > > 
> > >     net: export netdev_stats_to_stats64
> > >     
> > >     Some drivers use internal netdev stats member to store part of their
> > >     stats, yet advertize ndo_get_stats64() to implement some 64bit fields.
> > >     
> > >     Allow them to use netdev_stats_to_stats64() helper to make the copy of
> > >     netdev stats before they compute their 64bit counters.
> > > 
> > >
> > 
> > Definitely looks cleaner now. Thanks!
> 
> Well, no ;)
> 
> Please read again the changelog I copied, and highlight the word
> _before_
> 
> If you cant test the patch, please ask someone to do so.
> 
> 
>

Eric, do you mean like this below? If not, please illustrate.

+       netdev_stats_to_stats64(stats, &dev->stats);
+
+       do {
+               start = u64_stats_fetch_begin_bh(&rp->rx_stats.syncp);
+               stats->rx_packets = rp->rx_stats.packets;
+               stats->rx_bytes = rp->rx_stats.bytes;
+       } while (u64_stats_fetch_retry_bh(&rp->rx_stats.syncp, start));
+
+       do {
+               start = u64_stats_fetch_begin_bh(&rp->tx_stats.syncp);
+               stats->tx_packets = rp->tx_stats.packets;
+               stats->tx_bytes = rp->tx_stats.bytes;
+       } while (u64_stats_fetch_retry_bh(&rp->tx_stats.syncp, start));
+
+       return stats;
