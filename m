From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [PATCH] igb: Record hardware RX overruns in
	net_stats
Date: Wed, 6 May 2009 14:24:54 -0700 (Pacific Daylight Time)
Message-ID: <Pine.WNT.4.64.0905061418090.23772@ppwaskie-MOBL2.amr.corp.intel.com>
References: <20090505.115819.84151021.davem@davemloft.net>
	<Pine.LNX.4.64.0905052249110.1294@ask.diku.dk>
	<9929d2390905051432h795d183bh40fbe1beb35a4de9@mail.gmail.com>
	<20090505.143529.148721206.davem@davemloft.net>
	<1241595993.5172.4.camel@localhost.localdomain>
	<Pine.WNT.4.64.0905060048570.22956@ppwaskie-MOBL2.amr.corp.intel.com>
	<1241615351.5172.60.camel@localhost.localdomain>
	<1241643595.2234.9.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "hawk@diku.dk" <hawk@diku.dk>,
	"e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>, "Brandeburg,
	Jesse" <jesse.brandeburg@intel.com>, "Ronciak,
	John" <john.ronciak@intel.com>, "Kirsher,
	Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>
To: Jesper Dangaard Brouer <jdb@comx.dk>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1241643595.2234.9.camel@localhost.localdomain>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Wed, 6 May 2009, Jesper Dangaard Brouer wrote:

> On Wed, 2009-05-06 at 15:09 +0200, Jesper Dangaard Brouer wrote:
> > > In the SRRCTL registers, there is a DROP_EN bit, bit 31.  If this 
> > > bit is set to 1b for the queue in question, then the packet will be 
> > > dropped when there are no buffers in the packet buffer.  This does
> > not 
> > > mean the FIFO is full or has been overrun, it just means there's no
> > more
> > > descriptors available in the Rx ring for that queue.  In this case,
> > RNBC 
> > > is incremented, MPC is not.
> > 
> > My experience is that if DROP_EN bit is *set*. Then I cannot find the
> > drop count anywhere... not in RNBC and not in MPC ... and I can still
> > see the drops with my netfilter module mp2t.
> > 
> > ethtool -S eth21 | egrep 'rx_no_buffer_count|rx_miss'
> >      rx_no_buffer_count: 0
> >      rx_missed_errors: 0
> > 
> > I'm guessing that the drop counters are now in the per queue RQDPC
> > register (Receive Queue Drop Packet Count), but reading that is not
> > implemented in the driver. 
> 
> Just did a quick implemenation in the driver, see draft patch below (not
> ready for inclusion yet!).
> 
> An my guess was correct, the drops count is stored per queue in RQDPC.
> The only really anoying thing is that this counter is only 12 bit, thus
> overruns can occur quickly.  (This reminds me of my drop count
> implemenation for Sun niu driver.  This counter has less bits that the 
> Sun counter, but at least it automatically clears on reads)
> 
> I'll post some more clean patches tomorrow...

Ok, so 82576 is much more like 82599 with the queue counters, but 
different enough to be annoying.  Yes, I'm seeing this in the data manual 
for 82576.  Honestly, we have too many damn counters for packet 
accounting.  I'm very happy you're getting what you wanted now.  Your 
patch looks reasonable to me; please let us know if you have any other 
questions about the part that we might be able to help with.

Cheers,
-PJ Waskiewicz

------------------------------------------------------------------------------
The NEW KODAK i700 Series Scanners deliver under ANY circumstances! Your
production scanning environment may not be a perfect world - but thanks to
Kodak, there's a perfect scanner to get the job done! With the NEW KODAK i700
Series Scanner you'll get full speed at 300 dpi even with all image 
processing features enabled. http://p.sf.net/sfu/kodak-com
