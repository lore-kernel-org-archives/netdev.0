From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: netif_rx packet dumping
Date: Fri, 4 Mar 2005 11:54:22 -0800
Message-ID: <20050304115422.2640cf91@dxpl.pdx.osdl.net>
References: <20050303123811.4d934249@dxpl.pdx.osdl.net>
	<20050303125556.6850cfe5.davem@davemloft.net>
	<1109884688.1090.282.camel@jzny.localdomain>
	<20050303132143.7eef517c@dxpl.pdx.osdl.net>
	<1109885065.1098.285.camel@jzny.localdomain>
	<20050303133237.5d64578f.davem@davemloft.net>
	<20050303135416.0d6e7708@dxpl.pdx.osdl.net>
	<Pine.LNX.4.58.0503031657300.22311@tesla.psc.edu>
	<1109888811.1092.352.camel@jzny.localdomain>
	<20050304195239.GA13262@iglesias.dyn.ee>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.ca>, John Heffner <jheffner@psc.edu>,
        "David S.
 Miller" <davem@davemloft.net>, rhee@eos.ncsu.edu,
        Yee-Ting.Li@nuim.ie, baruch@ev-en.org, netdev@oss.sgi.com
To: Edgar E Iglesias <edgar.iglesias@axis.com>
In-Reply-To: <20050304195239.GA13262@iglesias.dyn.ee>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 4 Mar 2005 20:52:39 +0100
Edgar E Iglesias <edgar.iglesias@axis.com> wrote:

> On Thu, Mar 03, 2005 at 05:26:51PM -0500, jamal wrote:
> > On Thu, 2005-03-03 at 17:02, John Heffner wrote:
> > > On Thu, 3 Mar 2005, Stephen Hemminger wrote:
> > > > Maybe a simple Random Exponential Drop (RED) would be more friendly.
> > > 
> > > That would probably not be appropriate.  This queue is only for absorbing
> > > micro-scale bursts.  It should not hold any data in steady state like a
> > > router queue can.  The receive window can handle the macro scale flow
> > > control.
> > 
> > recall this is a queue that is potentially shared by many many flows
> > from potentially many many interfaces i.e it deals with many many
> > micro-scale bursts.
> > Clearly, the best approach is to have lots and lots of memmory and to
> > make that queue real huge so it can cope with all of them all the time.
> > We dont have that luxury - If you restrict the queue size, you will have
> > to drop packets... Which ones?
> > Probably simplest solution is to leave it as is right now and just
> > adjust the contraints based on your system memmory etc.
> > 
> 
> Why not have smaller queues but per interface? this would avoid
> introducing too much latency and keep memory consumption low
> but scale as we add more interfaces. It would also provide some
> kind of fair queueing between the interfaces to avoid highspeed 
> nics to starve lowspeed ones.

That would require locking and effectively turn every device
into a NAPI device.

> Queue length would still be an issue though, should somehow be 
> related to interface rate and acceptable introduced latency.
> 
> Regarding RED and other more sophisticated algorithms, I assume
> this is up to the ingress qdisc to take care of. What the queues
> before the ingress qdiscs should do, is to avoid introducing
> too much latency. In my opinion, low latency or high burst
> tolerance should be the choice of the admin, like for egress.
> 

All this happens at a much lower level before the ingress qdisc
(which is optional) gets involved.
