From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] batched tc to improve change throughput
Date: 18 Jan 2005 09:29:52 -0500
Message-ID: <1106058592.1035.95.camel@jzny.localdomain>
References: <20050117152312.GC26856@postel.suug.ch>
	 <1105976711.1078.1.camel@jzny.localdomain>
	 <20050117160539.GD26856@postel.suug.ch>
	 <1105979807.1078.16.camel@jzny.localdomain>
	 <20050117165626.GE26856@postel.suug.ch>
	 <1106002197.1046.19.camel@jzny.localdomain>
	 <20050118134406.GR26856@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, Stephen Hemminger <shemminger@osdl.org>,
        netdev@oss.sgi.com, Werner Almesberger <werner@almesberger.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050118134406.GR26856@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2005-01-18 at 08:44, Thomas Graf wrote:
> * jamal <1106002197.1046.19.camel@jzny.localdomain> 2005-01-17 17:49
> > On Mon, 2005-01-17 at 11:56, Thomas Graf wrote:
> > > /**
> > >  * filter dla_fp
> > >  * match DLA traffic at lower watermark
> > >  */
> > > tc filter add
> > > 	dev %DEV
> > > 	parent 1:12
> > > 	prio 40
> > > 	protocol all
> > > 	basic match meta(nfmark eq %LOW_WATERMARK)
> > > 		    and (
> > > 		    	nbyte("\x0\x1\x2\x3\x4" at 4 layer 2) /* 00 01 02 03 04 (dla fp) */
> > > 			or u32(ip src 10.0.0.0/8)
> > > 		    )
> > > 	flowid 1:20
> > > 
> > > 
> > 
> > It does look clean. - btw look at Werners approach on tcng as well.
> 
> I'm aware of it but naturally it always lags behind a bit and keeping
> it up to date requires quite some work and I already have problems
> finding the time for my own changes ;-> 
> 

I think it is worth getting mr. Almesbergers view. CCed him.

> > Another thing that would be really neat is to have a iso like cli
> > (something like what zebra has) so you can go down the parse tree to
> > say the ematch level and just start typing away these commands.
> > Should probably be easy to rip off the vtysh stuff off zebra or
> > use libio or something along those lines to do this.
> 
> I wouldn't call it easy but it's doable. 

I dont think its hard at all. It would take me, cycles pending, not more
than a day to whip something off libio. 

> I'm not sure if
> entering/leaving subsystem features makes any sense. I find a context
> help by pressing '?' and normal completion most useful. It's not
> that I dislike your idea but I think it's not worth it.

What doesnt make sense or is not worth it?

Two problems that are to be solved - whatever the solution is, it needs
to address them:

a) usability. 
i) I dont need to remember how the parse tree looks like or where i am
on the parse tree.
I go:
tc <enter>
tc> ?
i get some help on the next levels.
ii) I should be able to ssh to this thing from some remote location.
This way i can write some scripts to automate things

b) extrenous typing on command line.
I go to the filter level

u32> ?
gives me help
u32> context
filter dev lo parent ffff: protocol ip prio 10
u32> add 
u32> match ip src 10.0.0.21/32 flowid 1:16 action drop
u32> match ip src 0/0 flowid 1:16 action ok
u32> commit
filters submitted ..
u32> .. //takes you up one
u32> ls
listing here of filter dev lo parent ffff: protocol ip prio 10
..
..
u32> /qdisc/dev/eth0
now into the qdisc level context for eth0

>  Actualy,
> I've been working on such a thing (called netsh) being a frontend
> to iproute2 + tc + ... with 3 modes:
>  - batched mode (-f)

this is useful. 

>  - interactive shell supporting context help + completion

MUST

>  - call over arguments

Dont understand this.

> It includes a quite easy to use API to define the grammar which
> can be used by readline to do the completion and print context
> aware help. 

what does readline provide you again?

> It could be easly ported to iproute2 but every
> module needs to be changed, luckly this can happen step by
> step. I will port it to iproute2 and transform one of the
> easier modules like neighbour to it and we can see if we like
> it.

I think iproute2 should stay as is - dont wanna break someones scripts
or make it fatter than it is already. Any app to provide the above
should be standalone.

cheers,
jamal
