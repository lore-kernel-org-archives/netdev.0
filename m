From: Mark Brown <broonie@opensource.wolfsonmicro.com>
Subject: Re: 100Mbit ethernet performance on embedded devices
Date: Fri, 28 Aug 2009 18:35:13 +0100
Message-ID: <20090828173511.GA4422@sirena.org.uk>
References: <20090819145057.GA25400@sig21.net>
 <20090819153534.GC30013@shareable.org>
 <20090820125649.GA29029@sig21.net>
 <20090828144138.GB7375@sig21.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamie Lokier <jamie@shareable.org>, linux-embedded@vger.kernel.org,
	netdev@vger.kernel.org
To: Johannes Stezenbach <js@sig21.net>
Return-path: <linux-embedded-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090828144138.GB7375@sig21.net>
Sender: linux-embedded-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 28, 2009 at 04:41:38PM +0200, Johannes Stezenbach wrote:
> On Thu, Aug 20, 2009 at 02:56:49PM +0200, Johannes Stezenbach wrote:

> > which came with the 2.6.20 kernel.  The delay between irq ->
> > netif_rx_schedule() -> NET_RX_SOFTIRQ ->  ->poll()  doesn't seem
> > to be long enough.  But of course my understanding of NAPI is
> > very limited, probably I missed something...

> It would've been nice to get a comment on this.  Yeah I know,
> old kernel, non-mainline driver...

> On this platform NAPI seems to be a win when receiving small packets,
> but not for a single max-bandwidth TCP stream.  The folks at
> stlinux.com seem to be using a dedicated hw timer to delay
> the NAPI poll() calls:
> http://www.stlinux.com/drupal/kernel/network/stmmac-optimizations

> This of course adds some latency to the packet processing,
> however in the single TCP stream case this wouldn't matter.

Does your actual system have any appreciable CPU loading?  If so that
will normally have the same effect as inserting a delay in the RX path.
Some of the numbers will often look worse with NAPI when the system is
lightly loaded (though not normally throughput).
