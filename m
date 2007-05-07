From: David Acker <dacker@roinet.com>
Subject: Re: [PATCH] e100 rx: or s and el bits
Date: Mon, 07 May 2007 11:27:19 -0400
Message-ID: <463F4557.9030901@roinet.com>
References: <200705011124.l41BOEG4007662@sullivan.realtime.net>
	<46375664.8030701@roinet.com> <4638F2B2.2000103@roinet.com>
	<463BA906.30205@roinet.com>
	<85f07fc58d5ed2147d5214d0f0b4fe32@bga.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Auke Kok <auke-jan.h.kok@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Scott Feldman <sfeldma@pobox.com>,
	John Ronciak <john.ronciak@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Milton Miller <miltonm@bga.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <85f07fc58d5ed2147d5214d0f0b4fe32@bga.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Milton Miller wrote:
> While this will help the problem with the cache-incoherent DMA systems 
> not running, it guarantees the hardware will stop every <ring-size> 
> packets and wait for the cpu to respond to an interrupt.  It would seem 
> that this will lead to packet drops.
> 
Well, in NAPI mode, we the CPU may poll its way to the last buffer 
without having to go through an interrupt cycle.  You are right that 
buffers would probably get dropped between the time the hardware hit the 
S-bit and the CPU caught up.

> [download manual from site in source file]
> 
> In fact 6.4.3.4 says 82557 will start dropping frames immediately.
> 
> Looking at the descriptions around page 101:
> (1) The link pointer, S, and EL is read when hw starts recieving the frame.
> (2) Its pretty clear EL overrides S from the order of the descriptions 
> in the text.
My testing confirms this.

> (3) 6.4.3.3.1 #4 looks intresting -- That is a RFD with size 0 skips 
> frame fill and goes to the next packet.
> 
> How about putting a zero length descriptor in consistent memory to 
> suspend the rx unit before the last real frame?   In other words  fr0 -> 
> fr1 ... frN-2 -> frN-1 -> WaitHere0 -> FrN.   We could then have 2 such 
> frames, and when we refill modify FrN to the new chain, with the 
> WaitHere1 as its next-to-last, do the syncs, then clear the S bit on 
> WaitHere0.   When the rx passes WaitHere0 we can reclaim it for the next 
> use (might want a slightly larger pool, basically need RxRingSize / 
> RxRingFillBatch such frames.

Hmm...I will take a look at this.  My test worked over the weekend by 
the way.  A patch will be coming.
-Ack

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
