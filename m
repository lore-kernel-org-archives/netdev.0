From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] batched tc to improve change throughput
Date: Tue, 18 Jan 2005 14:44:06 +0100
Message-ID: <20050118134406.GR26856@postel.suug.ch>
References: <20050117152312.GC26856@postel.suug.ch> <1105976711.1078.1.camel@jzny.localdomain> <20050117160539.GD26856@postel.suug.ch> <1105979807.1078.16.camel@jzny.localdomain> <20050117165626.GE26856@postel.suug.ch> <1106002197.1046.19.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, Stephen Hemminger <shemminger@osdl.org>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1106002197.1046.19.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1106002197.1046.19.camel@jzny.localdomain> 2005-01-17 17:49
> On Mon, 2005-01-17 at 11:56, Thomas Graf wrote:
> > /**
> >  * filter dla_fp
> >  * match DLA traffic at lower watermark
> >  */
> > tc filter add
> > 	dev %DEV
> > 	parent 1:12
> > 	prio 40
> > 	protocol all
> > 	basic match meta(nfmark eq %LOW_WATERMARK)
> > 		    and (
> > 		    	nbyte("\x0\x1\x2\x3\x4" at 4 layer 2) /* 00 01 02 03 04 (dla fp) */
> > 			or u32(ip src 10.0.0.0/8)
> > 		    )
> > 	flowid 1:20
> > 
> > 
> 
> It does look clean. - btw look at Werners approach on tcng as well.

I'm aware of it but naturally it always lags behind a bit and keeping
it up to date requires quite some work and I already have problems
finding the time for my own changes ;->

> Another thing that would be really neat is to have a iso like cli
> (something like what zebra has) so you can go down the parse tree to
> say the ematch level and just start typing away these commands.
> Should probably be easy to rip off the vtysh stuff off zebra or
> use libio or something along those lines to do this.

I wouldn't call it easy but it's doable. I'm not sure if
entering/leaving subsystem features makes any sense. I find a context
help by pressing '?' and normal completion most useful. It's not
that I dislike your idea but I think it's not worth it. Actualy,
I've been working on such a thing (called netsh) being a frontend
to iproute2 + tc + ... with 3 modes:
 - batched mode (-f)
 - interactive shell supporting context help + completion
 - call over arguments

It includes a quite easy to use API to define the grammar which
can be used by readline to do the completion and print context
aware help. It could be easly ported to iproute2 but every
module needs to be changed, luckly this can happen step by
step. I will port it to iproute2 and transform one of the
easier modules like neighbour to it and we can see if we like
it.
