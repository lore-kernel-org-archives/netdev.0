From: John Heffner <jheffner@psc.edu>
Subject: Re: netif_rx packet dumping
Date: Thu, 3 Mar 2005 18:48:50 -0500 (EST)
Message-ID: <Pine.LNX.4.58.0503031818270.22311@tesla.psc.edu>
References: <20050303123811.4d934249@dxpl.pdx.osdl.net>
 <20050303125556.6850cfe5.davem@davemloft.net> <1109884688.1090.282.camel@jzny.localdomain>
 <20050303132143.7eef517c@dxpl.pdx.osdl.net> <1109885065.1098.285.camel@jzny.localdomain>
 <20050303133237.5d64578f.davem@davemloft.net> <20050303135416.0d6e7708@dxpl.pdx.osdl.net>
 <Pine.LNX.4.58.0503031657300.22311@tesla.psc.edu> <1109888811.1092.352.camel@jzny.localdomain>
 <20050303151606.3587394f@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: hadi@cyberus.ca, "David S. Miller" <davem@davemloft.net>,
        rhee@eos.ncsu.edu, Yee-Ting.Li@nuim.ie, baruch@ev-en.org,
        netdev@oss.sgi.com
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050303151606.3587394f@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 3 Mar 2005, Stephen Hemminger wrote:

> Another alternative would be some form of adaptive threshold,
> something like adaptive drop tail described in this paper.
> http://www.ee.cityu.edu.hk/~gchen/pdf/ITC18.pdf
>
> Since netif_rx is running at interrupt time, it has to be simple/quick.

All these AQM schemes are trying to solve a fundamentally different
problem.  With TCP at least, the only congestion experienced at this point
will be transient, so you do not want to send any congestion signals (drop
packets) if you can avoid it at all.  Making the limit as high as you can
tolerate seems like the best thing to me.

I am a bit worried that removing the throttling *is* a DOS risk though.

  -John
