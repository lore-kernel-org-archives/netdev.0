From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] batched tc to improve change throughput
Date: 19 Jan 2005 09:13:30 -0500
Message-ID: <1106144009.1047.989.camel@jzny.localdomain>
References: <20050117152312.GC26856@postel.suug.ch>
	 <1105976711.1078.1.camel@jzny.localdomain>
	 <20050117160539.GD26856@postel.suug.ch>
	 <1105979807.1078.16.camel@jzny.localdomain>
	 <20050117165626.GE26856@postel.suug.ch>
	 <1106002197.1046.19.camel@jzny.localdomain>
	 <20050118134406.GR26856@postel.suug.ch>
	 <1106058592.1035.95.camel@jzny.localdomain>
	 <20050118145830.GS26856@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, Stephen Hemminger <shemminger@osdl.org>,
        netdev@oss.sgi.com, Werner Almesberger <werner@almesberger.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050118145830.GS26856@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2005-01-18 at 09:58, Thomas Graf wrote:
> * jamal <1106058592.1035.95.camel@jzny.localdomain> 2005-01-18 09:29
> > On Tue, 2005-01-18 at 08:44, Thomas Graf wrote:
> > > I'm not sure if
> > > entering/leaving subsystem features makes any sense. I find a context
> > > help by pressing '?' and normal completion most useful. It's not
> > > that I dislike your idea but I think it's not worth it.
> > 
> > What doesnt make sense or is not worth it?
> 
> My very personal opinion is that it's not worth it.

Ok, lets discuss more see if we can change that ;->

> > a) usability. 
> > i) I dont need to remember how the parse tree looks like or where i am
> > on the parse tree.
> > I go:
> > tc <enter>
> > tc> ?
> > i get some help on the next levels.
> > ii) I should be able to ssh to this thing from some remote location.
> > This way i can write some scripts to automate things
> > 
> > b) extrenous typing on command line.
> > I go to the filter level
> > 
> > u32> ?
> > gives me help
> > u32> context
> > filter dev lo parent ffff: protocol ip prio 10
> > u32> add 
> > u32> match ip src 10.0.0.21/32 flowid 1:16 action drop
> > u32> match ip src 0/0 flowid 1:16 action ok
> > u32> commit
> > filters submitted ..
> 
> What do you if there is an error? To what kind of context do you
> go? Let's say the kernel reports -EINVAL.
> 

As Lennert was saying, puke whatever the kernel said and allow for
rollback. i.e undo the first one if it succeeded for example.

> tgr:axs ~/dev/netconfig/src ./netconfig

[some really neat stuff deleted for brevity]

> Again, It's not that I dislike contexts but in the end it all
> gets down to make error correction as easy as possible. Everytime
> you request a completion or context help the command will get
> parsed and a very verbose message including the possibilities you
> have will be printed and you can correct your error.
> 
> It's more typing work I know, but usually one only types the first
> 1..3 chars of the commands.
> 

Same as in what i showed. Probably not a very big deal.
The one neat thing about the context approach is it allows you to
remember state easily. As an example, after commiting those two u32
filters and you want to undo, you then remember what it is that you can
undo. 

What you have is really nice because you could use standard tools such
as "| grep forsomething | formatit etc" to manipulate further. This
would be hard to do in the case of what i described earlier.

The best solution we can have is to have a mix of the two approaches
IMO.

> > > It includes a quite easy to use API to define the grammar which
> > > can be used by readline to do the completion and print context
> > > aware help. 
> > 
> > what does readline provide you again?
> 
> It basically takes over the reading of a line and allows manipulation
> of the input buffer. It implements all the useful line editing like
> in bash and helps with completion. You can bind the '?' key to a
> help function so that '?' will not be printed on the screen but instead
> the help text is printed and you get back your original line untouched.
> It also gives the user a chance to bind keys to certain actions so
> everyone can keep the bindings they like with the additional
> possibilities to export functions so one could for example bind C-N
> to "list-neighbours".

These are all very nice features to have.

> > I think iproute2 should stay as is - dont wanna break someones scripts
> > or make it fatter than it is already. Any app to provide the above
> > should be standalone.
> 
> Well, you mean like generating iproute2 input? This means we'd have to
> reimplement the logic twice and handling errors from iproute2 gets
> really hard. It's not a problem to keep the old way of iproute2 as-is.

What i mean is that we should probably leave iproute2 code alone so that
people can run old scripts etc with it.  i.e the netsh tool should just
either reuse libnetlink and add any things to it or create a brand new
library.

cheers,
jamal
