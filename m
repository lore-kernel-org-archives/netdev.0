From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: [Bugme-new] [Bug 6682] New: BUG: soft lockup detected on CPU#0! / ksoftirqd takse 100% CPU
Date: Tue, 20 Jun 2006 17:28:35 +0200
Message-ID: <17560.5155.562715.635409@robur.slu.se>
References: <200606122311.k5CNBMEx007518@fire-2.osdl.org>
	<20060619152010.5c648b97.akpm@osdl.org>
	<20060620123253.GA26122@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org,
	Dipankar Sarma <dipankar@in.ibm.com>,
	"Paul E. McKenney" <paulmck@us.ibm.com>,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>, alchemyx@uznam.net.pl,
	Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.slu.se ([130.238.96.70]:3220 "EHLO mx1.slu.se")
	by vger.kernel.org with ESMTP id S1751316AbWFTP2p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2006 11:28:45 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060620123253.GA26122@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hello!

Yes seems the system is very loaded for some reason 

> > sometimes a day) we get 100% usage on ksoftirqd/0 and following messages 
   in logs:

as all softirq's are run via ksoftirqd. That's still OK but why don't the 
watchdog get any CPU share at all? Mismatch in priorities? 

Herbert Xu writes:
> On Mon, Jun 19, 2006 at 10:20:10PM +0000, Andrew Morton wrote:
 > >
 > > >  [<c02396f9>] dev_queue_xmit+0xe0/0x203
 > > >  [<c0250de8>] ip_output+0x1e1/0x237
 > > >  [<c024f3f5>] ip_forward+0x181/0x1df
 > > >  [<c024e21a>] ip_rcv+0x40c/0x485
 > > >  [<c0239bd0>] netif_receive_skb+0x12f/0x165
 > > >  [<f885aa4c>] e1000_clean_rx_irq+0x389/0x410 [e1000]
 > > >  [<f885a1ca>] e1000_clean+0x94/0x12f [e1000]
 > > >  [<c0239d5a>] net_rx_action+0x69/0xf0
 > > >  [<c011a305>] __do_softirq+0x55/0xbd
 > > >  [<c011a39a>] do_softirq+0x2d/0x31
 > > >  [<c011a3f8>] local_bh_enable+0x5a/0x65
 > > >  [<c024a0a1>] rt_run_flush+0x5f/0x80

Normal for a router...

 > Could you tell us the frequency of route updates on this machine?
 > Route updates are pretty expensive especially when a large number
 > of flows hits your machine right afterwards.

Yes flush is costly an unfortunly hard to avoid. We discussed this a
bit before...

 > You can monitor this by running ip mon.  You might just be getting
 > bogus route updates causing unnecessary flushes to the routing cache.

Just sampled 10 min in one of routers with full 2 * (Full BGP). Well
remember Zebra/Quagga has just one set in kernel. Anyway during the 
10 minutes I looked I got 4 (insertion/deletions)/second in average.

Cheers.
					--ro

 
 
