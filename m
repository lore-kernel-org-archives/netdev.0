From: John Heffner <jheffner@psc.edu>
Subject: Re: netif_rx packet dumping
Date: Thu, 3 Mar 2005 22:10:55 -0500 (EST)
Message-ID: <Pine.LNX.4.58.0503032116020.28187@tesla.psc.edu>
References: <20050303125556.6850cfe5.davem@davemloft.net>
 <1109884688.1090.282.camel@jzny.localdomain> <20050303132143.7eef517c@dxpl.pdx.osdl.net>
 <1109885065.1098.285.camel@jzny.localdomain> <20050303133237.5d64578f.davem@davemloft.net>
 <20050303135416.0d6e7708@dxpl.pdx.osdl.net> <Pine.LNX.4.58.0503031657300.22311@tesla.psc.edu>
 <1109888811.1092.352.camel@jzny.localdomain> <20050303151606.3587394f@dxpl.pdx.osdl.net>
 <Pine.LNX.4.58.0503031818270.22311@tesla.psc.edu> <20050304014227.GB28874@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Stephen Hemminger <shemminger@osdl.org>, baruch@ev-en.org,
        netdev@oss.sgi.com
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20050304014227.GB28874@xi.wantstofly.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 4 Mar 2005, Lennert Buytenhek wrote:

> On Thu, Mar 03, 2005 at 06:48:50PM -0500, John Heffner wrote:
>
> > All these AQM schemes are trying to solve a fundamentally different
> > problem.  With TCP at least, the only congestion experienced at this point
> > will be transient, so you do not want to send any congestion signals (drop
> > packets) if you can avoid it at all.  Making the limit as high as you can
> > tolerate seems like the best thing to me.
>
> If the traffic does not terminate locally (f.e. when doing routing),
> an insanely large queue has more disadvantages than advantages.
>
> If you're routing those exact same TCP packets on the way to their
> final destination, you run the risk of not sending out any congestion
> signals in the cases where you should, making your forwarding latency
> skyrocket (punishing all the other flows) in the process.


Yes.  In "as high as you can tolerate" latency is implicit. :)  This is
just as true whether forwarding or not.  Offhand I'd say 10 ms is a good
number (bursts should be shorter than this, but it's not too much
latency).

The forwarding case where you actually need congestion control, as opposed
to absorbing bursts, is pretty gross.  If you have a router (more likely
firewall) whose bottleneck is the CPU, then you're operating entirely in
you input queue.  Yuck.  In such a situation, if you don't want user
processes to get starved, you need to do throttling => bad for TCP.

  -John
