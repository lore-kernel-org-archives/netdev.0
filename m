From: Jean Delvare <khali@linux-fr.org>
Subject: Re: [PATCH] e1000: Real time packets and bytes statistics
Date: Thu, 12 Oct 2006 23:02:52 +0200
Message-ID: <20061012230252.8b5a1ebb.khali@linux-fr.org>
References: <20061011133557.8a404e24.khali@linux-fr.org>
	<4807377b0610111044u5eced127od8272797e63743a7@mail.gmail.com>
	<20061012103006.1367693a@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Jesse Brandeburg" <jesse.brandeburg@gmail.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-104-thursday.noc.nerim.net ([62.4.17.104]:34309 "EHLO
	mallaury.nerim.net") by vger.kernel.org with ESMTP id S1750804AbWJLVCs
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Oct 2006 17:02:48 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20061012103006.1367693a@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stephen,

On 10/11/06, Stephen Hemminger wrote:
> On Wed, 11 Oct 2006, Jesse Brandeburg wrote:
> > On 10/11/06, Jean Delvare wrote:
> > > Let the e1000 driver report the most important statistics (rx/tx_bytes
> > > and rx/tx_packets) in real time, rather than every other second. This
> > > is similar to what the e100 driver is doing.
> > > (...)
> > > --- linux-2.6.19-rc1.orig/drivers/net/e1000/e1000_main.c        2006-10-11 10:53:49.000000000 +0200
> > > +++ linux-2.6.19-rc1/drivers/net/e1000/e1000_main.c     2006-10-11 11:34:41.000000000 +0200
> > > @@ -3118,6 +3118,8 @@
> > >                        e1000_tx_map(adapter, tx_ring, skb, first,
> > >                                     max_per_txd, nr_frags, mss));
> > >
> > > +       adapter->net_stats.tx_packets++;
> > > +       adapter->net_stats.tx_bytes += skb->len;
> > >         netdev->trans_start = jiffies;
> > 
> > this is the part I'm most worried about.  as I believe it to be
> > incorrect for TSO packets.  Maybe something like?
> > +       if (skb_shinfo(skb)->gso_segs)
> > +              adapter->net_stats.tx_packets += skb_shinfo(skb)->gso_segs;
> > +       else
> > +              adapter->net_stats.tx_packets++;
> > +       adapter->net_stats.tx_bytes += skb->len;
> >         netdev->trans_start = jiffies;
> > 
> > skb len will still be off by some amount, because the skb->data
> > (header) is replicated across each gso segment but only counted once
> > this way, but hopefully someone will pipe up with a good way to
> > compute that.
> 
> You might want to put the tx values in a per-cpu structure and
> sum later.  Incrementing statistics can actually be a performance
> bottleneck on SMP tests, because it causes lots of cache thrashing.

I don't really see how this would be implemented. Can you please point
me to other drivers which do it that way?

Thanks,
-- 
Jean Delvare
