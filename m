From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] via-rhine: add 64bit statistics.
Date: Wed, 23 Jan 2013 08:17:18 -0800
Message-ID: <1358957838.12374.805.camel@edumazet-glaptop>
References: <50fff42d.094e640a.3ace.6ae4@mx.google.com>
	 <1358951884.12374.790.camel@edumazet-glaptop>
	 <510004a3.2444ec0a.1ba7.ffff98b3@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Jamie Gloudon <jamie.gloudon@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:45626 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756480Ab3AWQRW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 11:17:22 -0500
Received: by mail-pb0-f43.google.com with SMTP id jt11so3385446pbb.2
        for <netdev@vger.kernel.org>; Wed, 23 Jan 2013 08:17:21 -0800 (PST)
In-Reply-To: <510004a3.2444ec0a.1ba7.ffff98b3@mx.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-01-23 at 11:41 -0400, Jamie Gloudon wrote:
> On Wed, Jan 23, 2013 at 06:38:04AM -0800, Eric Dumazet wrote:
> > On Wed, 2013-01-23 at 10:31 -0400, Jamie Gloudon wrote:
> > > Switch to use ndo_get_stats64 to get 64bit statistics.
> > > 
> > > Signed-off-by: Jamie Gloudon <jamie.gloudon@gmail.com>
> > > ---
> > 
> > > +
> > > +	stats->rx_errors = dev->stats.rx_errors;
> > > +	stats->tx_errors = dev->stats.tx_errors;
> > > +	stats->rx_dropped = dev->stats.rx_dropped;
> > > +	stats->tx_dropped = dev->stats.tx_dropped;
> > > +	stats->collisions = dev->stats.collisions;
> > > +
> > > +	stats->rx_length_errors = dev->stats.rx_length_errors;
> > > +	stats->rx_crc_errors = dev->stats.rx_crc_errors;
> > > +	stats->rx_frame_errors = dev->stats.rx_frame_errors;
> > > +	stats->rx_fifo_errors = dev->stats.rx_fifo_errors;
> > > +	stats->rx_missed_errors = dev->stats.rx_missed_errors;
> > > +
> > > +	stats->tx_aborted_errors = dev->stats.tx_aborted_errors;
> > > +	stats->tx_carrier_errors = dev->stats.tx_carrier_errors;
> > > +	stats->tx_fifo_errors = dev->stats.tx_fifo_errors;
> > > +	stats->tx_heartbeat_errors = dev->stats.tx_heartbeat_errors;
> > > +	stats->tx_window_errors = dev->stats.tx_window_errors;
> > > +
> > > +	return stats;
> > >  }
> > >  
> > 
> > Hi Jamie
> > 
> > Please use netdev_stats_to_stats64() for this block
> > 
> > commit 77a1abf54f4b003ad6e59c535045b2ad89fedfeb
> > Author: Eric Dumazet <eric.dumazet@gmail.com>
> > Date:   Mon Mar 5 04:50:09 2012 +0000
> > 
> >     net: export netdev_stats_to_stats64
> >     
> >     Some drivers use internal netdev stats member to store part of their
> >     stats, yet advertize ndo_get_stats64() to implement some 64bit fields.
> >     
> >     Allow them to use netdev_stats_to_stats64() helper to make the copy of
> >     netdev stats before they compute their 64bit counters.
> > 
> >
> 
> Definitely looks cleaner now. Thanks!

Well, no ;)

Please read again the changelog I copied, and highlight the word
_before_

If you cant test the patch, please ask someone to do so.
