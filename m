From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: 2.6.0: something is leaking memory
Date: Sun, 4 Jan 2004 18:30:21 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0401041826400.2162@home.osdl.org>
References: <slrnbvgohn.1pb.erik@dexter.hensema.net>
 <Pine.LNX.4.58.0401041257290.2162@home.osdl.org> <slrnbvh1hd.jl6.erik@dexter.hensema.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, "David S. Miller" <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Erik Hensema <erik@hensema.net>
In-Reply-To: <slrnbvh1hd.jl6.erik@dexter.hensema.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Sun, 4 Jan 2004, Erik Hensema wrote:
> Linus Torvalds (torvalds@osdl.org) wrote:
> >
> > Can you do /proc/slabinfo too?
> 
> Sure, this is of course my currently running system, 4 days, 9:53
> uptime.
> 
> slabinfo - version: 2.0
> # name            <active_objs> <num_objs> <objsize> <objperslab> <pagesperslab> : tunables <batchcount> <limit> <sharedfactor> : slabdata <active_slabs> <num_slabs> <sharedavail>
> tcp6_sock          19729  19732   1024    4    1 : tunables   54   27    0 : slabdata   4933   4933      0

You've got 19 _megabytes_ allocated to "tcp6_sock", and they are all 
marked as "active". That's almost certainly the leaking bug.

Everything else looks reasonably normal.

> I do use IPv6. I've got three active tunnels and native IPv6 over
> ethernet.

Yeah, but there is no way you have 19 MB worth of sockets active for three 
tunnels.

David?

		Linus
