From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] batched tc to improve change throughput
Date: Wed, 19 Jan 2005 15:36:32 +0100
Message-ID: <20050119143632.GA26856@postel.suug.ch>
References: <20050117152312.GC26856@postel.suug.ch> <1105976711.1078.1.camel@jzny.localdomain> <20050117160539.GD26856@postel.suug.ch> <1105979807.1078.16.camel@jzny.localdomain> <20050117165626.GE26856@postel.suug.ch> <1106002197.1046.19.camel@jzny.localdomain> <20050118134406.GR26856@postel.suug.ch> <1106058592.1035.95.camel@jzny.localdomain> <20050118145830.GS26856@postel.suug.ch> <1106144009.1047.989.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, Stephen Hemminger <shemminger@osdl.org>,
        netdev@oss.sgi.com, Werner Almesberger <werner@almesberger.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1106144009.1047.989.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1106144009.1047.989.camel@jzny.localdomain> 2005-01-19 09:13
> On Tue, 2005-01-18 at 09:58, Thomas Graf wrote:
> > What do you if there is an error? To what kind of context do you
> > go? Let's say the kernel reports -EINVAL.
> > 
> 
> As Lennert was saying, puke whatever the kernel said and allow for
> rollback. i.e undo the first one if it succeeded for example.

Yes but this is not dependant on a context, is it? It is possible, I
have it working for most netlink messages but it is non trivial.

> > Again, It's not that I dislike contexts but in the end it all
> > gets down to make error correction as easy as possible. Everytime
> > you request a completion or context help the command will get
> > parsed and a very verbose message including the possibilities you
> > have will be printed and you can correct your error.
> > 
> > It's more typing work I know, but usually one only types the first
> > 1..3 chars of the commands.
> > 
> 
> Same as in what i showed. Probably not a very big deal.
> The one neat thing about the context approach is it allows you to
> remember state easily. As an example, after commiting those two u32
> filters and you want to undo, you then remember what it is that you can
> undo. 

So it seems you really want to do commit/rollback on context level.
Can you maybe explain this more verbosely, maybe it's easier than
I think.

The commit/rollback is only useful for groupings of requests such
as complete filtering configurations, the consistency of a single
addition should be handled properly by the kernel. The changes
in my tcf_exts patches solved most of them except for the indev
stuff.

> > > I think iproute2 should stay as is - dont wanna break someones scripts
> > > or make it fatter than it is already. Any app to provide the above
> > > should be standalone.
> > 
> > Well, you mean like generating iproute2 input? This means we'd have to
> > reimplement the logic twice and handling errors from iproute2 gets
> > really hard. It's not a problem to keep the old way of iproute2 as-is.
> 
> What i mean is that we should probably leave iproute2 code alone so that
> people can run old scripts etc with it.  i.e the netsh tool should just
> either reuse libnetlink and add any things to it or create a brand new
> library.

Well, libnetlink contains 1% of the code required, 99% are in the
modules and that's the hard work. Remeber libnl? netsh is based on it
and it took me 2 weeks to get neighbour and link code finished and
working, it is more powerful than ip now though. The basic features of
ip and tc isn't very difficult but there's quite a lot more in iproute2
which needs to be mostly rewritten to fit into a library.
