From: Thomas Graf <tgraf@suug.ch>
Subject: Re: dummy as IMQ replacement
Date: Mon, 31 Jan 2005 19:15:53 +0100
Message-ID: <20050131181553.GG31837@postel.suug.ch>
References: <1107123123.8021.80.camel@jzny.localdomain> <20050131135810.GC31837@postel.suug.ch> <1107181169.7840.184.camel@jzny.localdomain> <20050131151532.GE31837@postel.suug.ch> <1107186044.1076.11.camel@jzny.localdomain> <20050131155929.GF31837@postel.suug.ch> <1107189625.1076.77.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, Nguyen Dinh Nam <nguyendinhnam@gmail.com>,
        Remus <rmocius@auste.elnet.lt>, Andre Tomt <andre@tomt.net>,
        syrius.ml@no-log.org, Andy Furniss <andy.furniss@dsl.pipex.com>,
        Damion de Soto <damion@snapgear.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1107189625.1076.77.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Would be interesting to combine policing and random dropping to see 
> what happens. 

Indeed.

> Probably Linux may not even be the right place to do it to start with
> - rather simulations until you get it right then code it into Linux.

I haven't left ns sim so far, my calculations are based on some of the
linux specific cc modifications though, i.e. I modified ns sim a bit
to provide the same information. I'm thinking about moving to umlsim,
it should provide a better real world simulation.

> true - i was thinking of restoring stateless NAT at this level as well.
> So csum would be needed. The csum could be programmed to either
> validate only or recompute; those are the only two arguements to it that
> i could think of. I suppose first thing is to put out the eaction patch
> then add this action. I will try to sneak in some time this week and
> write the eaction.

Sounds good, we could put up a ematch csum for validation and a eaction
for recomputation. I'll wait for your code to show up.

> > Right, so we can do something like the meta ematch/action split. What
> > attributes to you intend to be modifieable? 
> 
> Essentially on ingress create state; i have to find my notes to give you
> precise answer. But one of the parameters was to select the level of
> state tracking (such as "track IP only" - not sure how doable that is
> with contrack)

So you want to have a generic conntrack action capable of dynamically
taking whatever information into account that the user requests? This
remembers me of the esfq effort which could benefit from this, it
extends sfq to take the definition for a flow as a parameter. We could
share some code here.

> Stateless NAT doesnt really need contracking. pedit (taught to speak
> english) + eaction csum should do it.

Right, given we don't need any reverse translation. Still it would be
neat to set the conntrack attributes so one could use iptables later
on, I'm not sure how doable this is though.

Something different...

This sounds all very good but I think we're still sucessfully ignoring
one of the most important points, usability. Most modifications over
the last few months have complicated things, introduced different behaviour
depending on compile time options and userspace tools which are either
outdated or having features being completely undocumented. Some of the
recent additions don't even show up in the usage text of iproute2. So
I think we should at least part time focus a little more on the big
picture and make things consitent and more useable. At least 50% of the
functionaility currently in mainline is completely unused because nobody
knows about it. I'm in no way against any of the recent additions but
maybe we can also put some more effort into usability.
