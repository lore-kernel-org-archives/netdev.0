From: jamal <hadi@cyberus.ca>
Subject: Re: dummy as IMQ replacement
Date: 31 Jan 2005 15:18:35 -0500
Message-ID: <1107202715.1075.559.camel@jzny.localdomain>
References: <1107123123.8021.80.camel@jzny.localdomain>
	 <20050131135810.GC31837@postel.suug.ch>
	 <1107181169.7840.184.camel@jzny.localdomain>
	 <20050131151532.GE31837@postel.suug.ch>
	 <1107186044.1076.11.camel@jzny.localdomain>
	 <20050131155929.GF31837@postel.suug.ch>
	 <1107189625.1076.77.camel@jzny.localdomain>
	 <20050131181553.GG31837@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Nguyen Dinh Nam <nguyendinhnam@gmail.com>,
        Remus <rmocius@auste.elnet.lt>, Andre Tomt <andre@tomt.net>,
        syrius.ml@no-log.org, Andy Furniss <andy.furniss@dsl.pipex.com>,
        Damion de Soto <damion@snapgear.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050131181553.GG31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2005-01-31 at 13:15, Thomas Graf wrote:

> I haven't left ns sim so far, my calculations are based on some of the
> linux specific cc modifications though, i.e. I modified ns sim a bit
> to provide the same information. I'm thinking about moving to umlsim,
> it should provide a better real world simulation.
> 

The problem is if theres any bugs in the way algos are implemented in
Linux you are influenced by that truth. Starting with ns and then
validating on Linux is a great way to do it.

> Sounds good, we could put up a ematch csum for validation and a eaction
> for recomputation. I'll wait for your code to show up.
> 

Cross your fingers; worst case by weekend i should get something out.

> > Essentially on ingress create state; i have to find my notes to give you
> > precise answer. But one of the parameters was to select the level of
> > state tracking (such as "track IP only" - not sure how doable that is
> > with contrack)
> 
> So you want to have a generic conntrack action capable of dynamically
> taking whatever information into account that the user requests? This
> remembers me of the esfq effort which could benefit from this, it
> extends sfq to take the definition for a flow as a parameter. We could
> share some code here.
> 

I dont think contrack was designed for this kind of effort. If we totaly
fail to do it using contrack then we could go a different path.
sfq already stores some rough view of the state; not sure if it can
benefit from this.

> > Stateless NAT doesnt really need contracking. pedit (taught to speak
> > english) + eaction csum should do it.
> 
> Right, given we don't need any reverse translation. Still it would be
> neat to set the conntrack attributes so one could use iptables later
> on, I'm not sure how doable this is though.
> 

If you are NATing (stateless) you should enter rules for both
directions; Maybe we could write a wrapper where user only enters
outgoing rule and that automatically generates the incoming rule as
well.

> Something different...
> 
> This sounds all very good but I think we're still sucessfully ignoring
> one of the most important points, usability. 

Absolutely.

> Most modifications over
> the last few months have complicated things, introduced different behaviour
> depending on compile time options and userspace tools which are either
> outdated or having features being completely undocumented. Some of the
> recent additions don't even show up in the usage text of iproute2. So
> I think we should at least part time focus a little more on the big
> picture and make things consitent and more useable. At least 50% of the
> functionaility currently in mainline is completely unused because nobody
> knows about it. I'm in no way against any of the recent additions but
> maybe we can also put some more effort into usability.

I think the eactions etc are adding a lot of value towards usability.
Hasso Tepper was ealrier complaining about this same issue. 
As an example, I think u32 and ematches would improve a great deal now
and be more understandable. True, work/time still needs to be invested.

cheers,
jamal
