From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: RFC: NAPI packet weighting patch
Date: Sat, 4 Jun 2005 01:26:56 +0200
Message-ID: <20050603232656.GB21125@xi.wantstofly.org>
References: <20050603.120126.41874584.davem@davemloft.net> <Pine.CYG.4.58.0506031202280.3344@mawilli1-desk2.amr.corp.intel.com> <20050603.132257.23013342.davem@davemloft.net> <20050603.132922.63997492.davem@davemloft.net> <1117828169.4430.29.camel@rh4> <20050603205944.GC20623@xi.wantstofly.org> <1117830922.4430.44.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, mitch.a.williams@intel.com,
        hadi@cyberus.ca, john.ronciak@intel.com, jdmason@us.ibm.com,
        shemminger@osdl.org, netdev@oss.sgi.com, Robert.Olsson@data.slu.se,
        ganesh.venkatesan@intel.com, jesse.brandeburg@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Michael Chan <mchan@broadcom.com>
Content-Disposition: inline
In-Reply-To: <1117830922.4430.44.camel@rh4>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Jun 03, 2005 at 01:35:22PM -0700, Michael Chan wrote:

> > > Yes, in tg3, rx buffers are replenished and put back into the ring
> > > as completed packets are taken off the ring. But we don't tell the
> > > chip about these new buffers until we get to the end of the loop,
> > > potentially after a full quota of packets.
> > 
> > Which makes a lot more sense, since you'd rather do one MMIO write
> > at the end of the loop than one per iteration, especially if your
> > MMIO read (flush) latency is high.  (Any subsequent MMIO read will
> > have to flush out all pending writes, which'll be slow if there's
> > a lot of writes still in the queue.)
> 
> I agree on the merit of issuing only one IO at the end. What I'm saying
> is that doing so will make it similar to e1000 where all the buffers are
> replenished at the end. Isn't that so or am I missing something?

I think you're right: for e1000 as well as tg3, the NIC cannot use
the new RX buffers until the CPU breaks out of the poll loop.

I don't understand why reducing the weight apparently makes the e1000
go faster.  Perhaps as Robert said, the RX ring is not big enough and
that's why feeding RX buffers back to the chip more agressively might
help prevent overruns?

I would say that running with a N+64-entry RX ring and a weight of 64
should not show any worse behavior than running with a N+16-entry RX
ring with a weight of 16.  If anything, weight=64 should show _better_
performance than weight=16.  Something else must be going on.


--L
