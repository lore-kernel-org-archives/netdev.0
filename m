From: jamal <hadi@cyberus.ca>
Subject: Re: pktgen
Date: 29 Nov 2004 08:49:52 -0500
Message-ID: <1101736191.1044.196.camel@jzny.localdomain>
References: <20041124170948.GC18059@xi.wantstofly.org>
	 <16804.60621.990421.525393@robur.slu.se>
	 <20041125030450.GA24417@xi.wantstofly.org>
	 <16805.40983.937641.670275@robur.slu.se>
	 <20041127002841.GA17184@xi.wantstofly.org>
	 <20041127004325.GA17401@xi.wantstofly.org>
	 <16808.28005.74903.881087@robur.slu.se>
	 <20041127135354.GA24617@xi.wantstofly.org>
	 <20041127143923.GA25155@xi.wantstofly.org>
	 <1101567861.1044.87.camel@jzny.localdomain>
	 <20041128183143.GD6045@xi.wantstofly.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>, netdev@oss.sgi.com,
        Grant Grundler <grundler@parisc-linux.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20041128183143.GD6045@xi.wantstofly.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 2004-11-28 at 13:31, Lennert Buytenhek wrote:
> On Sat, Nov 27, 2004 at 10:04:22AM -0500, jamal wrote:

> 
> > It would be interesting to see a study in this area though.
> 
> Indeed.  Right now it feels like I'm just poking around in the dark.  I'm
> really interested by now in finding out exactly what part of packet TX is
> taking how long and where all my cycles are going.
> 
> I don't have an Itanic but it's still possible to instrument the driver
> and do some stuff Grant talks about in his OLS paper, something like the
> attached.  (Exports # of MMIO reads/writes/flushes in the RX frame/
> TX carrier/collision stats field.  Beware, flushes are double-counted
> as reads.  Produces lots of output.)
> 
> During a 10Mpkt pktgen session (~16 seconds), I'm seeing:
> - 131757 interrupts, ~8k ints/sec, ~76 pkts/int
> - 131789 pure MMIO reads (i.e. not counting MMIO reads intended as write
> 	flushes), which is E1000_READ_REG(icr) in the irq handler
> - 10263536 MMIO writes (which would be 1 per packet plus 2 per interrupt)
> - 131757 MMIO write flushes (readl() of the e1000 status register after
> 	re-enabling IRQs in dev->poll())
> 
> Pretty consistent with what Grant was seeing.
> 
> MMIO reads from the e1000 are somewhere between 2000 and 3000 cycles a
> pop on my hardware.  2400MHz CPU -> ~1us/each.  (Reading netdevice stats
> does ~50 of those in a row.)
> 

Reads are known to be expensive. Good to see how much they are reduced. 
Not sure if this applies to MMIO reads though. Grant?

cheers,
jamal
