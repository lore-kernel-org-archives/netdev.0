From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: netif_rx packet dumping
Date: Fri, 4 Mar 2005 02:42:27 +0100
Message-ID: <20050304014227.GB28874@xi.wantstofly.org>
References: <20050303125556.6850cfe5.davem@davemloft.net> <1109884688.1090.282.camel@jzny.localdomain> <20050303132143.7eef517c@dxpl.pdx.osdl.net> <1109885065.1098.285.camel@jzny.localdomain> <20050303133237.5d64578f.davem@davemloft.net> <20050303135416.0d6e7708@dxpl.pdx.osdl.net> <Pine.LNX.4.58.0503031657300.22311@tesla.psc.edu> <1109888811.1092.352.camel@jzny.localdomain> <20050303151606.3587394f@dxpl.pdx.osdl.net> <Pine.LNX.4.58.0503031818270.22311@tesla.psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>, hadi@cyberus.ca,
        "David S. Miller" <davem@davemloft.net>, rhee@eos.ncsu.edu,
        Yee-Ting.Li@nuim.ie, baruch@ev-en.org, netdev@oss.sgi.com
To: John Heffner <jheffner@psc.edu>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0503031818270.22311@tesla.psc.edu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Mar 03, 2005 at 06:48:50PM -0500, John Heffner wrote:

> > Another alternative would be some form of adaptive threshold,
> > something like adaptive drop tail described in this paper.
> > http://www.ee.cityu.edu.hk/~gchen/pdf/ITC18.pdf
> >
> > Since netif_rx is running at interrupt time, it has to be simple/quick.
> 
> All these AQM schemes are trying to solve a fundamentally different
> problem.  With TCP at least, the only congestion experienced at this point
> will be transient, so you do not want to send any congestion signals (drop
> packets) if you can avoid it at all.  Making the limit as high as you can
> tolerate seems like the best thing to me.

If the traffic does not terminate locally (f.e. when doing routing),
an insanely large queue has more disadvantages than advantages.

If you're routing those exact same TCP packets on the way to their
final destination, you run the risk of not sending out any congestion
signals in the cases where you should, making your forwarding latency
skyrocket (punishing all the other flows) in the process.


--L
