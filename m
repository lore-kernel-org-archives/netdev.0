From: jamal <hadi@cyberus.ca>
Subject: Re: [PKT_SCHED]: Allow using nfmark as key in U32 classifier.
Date: 30 Dec 2004 23:58:31 -0500
Message-ID: <1104469111.1049.219.camel@jzny.localdomain>
References: <20041228221021.GF32419@postel.suug.ch>
	 <1104275197.1100.276.camel@jzny.localdomain>
	 <20041228231916.GG32419@postel.suug.ch>
	 <1104277165.1100.291.camel@jzny.localdomain>
	 <20041229000928.GH32419@postel.suug.ch>
	 <1104282811.1090.314.camel@jzny.localdomain>
	 <20041229124842.GI32419@postel.suug.ch>
	 <1104330054.1089.329.camel@jzny.localdomain>
	 <20041229150140.GJ32419@postel.suug.ch>
	 <1104335620.1025.22.camel@jzny.localdomain>
	 <20041230174313.GB32419@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041230174313.GB32419@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2004-12-30 at 12:43, Thomas Graf wrote:
> * jamal <1104335620.1025.22.camel@jzny.localdomain> 2004-12-29 10:53

> > If i store some ID that would tell me "IP" when i dump then i can pretty
> > print it in english in user space using ip_print().
> 
> Understood, we could store a map in userspace mapping those IDs to
> pretty english match descriptions. I think avoiding to hardcode those
> ids but rather just hold it for userspace is the best thing. 

We may be in sync:
I was thinking of just teaching tc to stash something there that it
understands on how to translate. Thinking about it now, this may not
be sufficient: perhaps we need a few bits in the selector to identify
the owner who installed the rule to begin with. Then it would be safe to
interpret the meaning of the ID (by the same app). Did you say there
were some unused bits in the selector?

> OTOH, if
> we give unique ids to matches we can use it instead of a separate ID.

Note: The above id i was talking about is "opaque" i.e the real meaning
of it is only known to the user space app that installed it (unloess you
want to define things in kernel headers)

> Unique in terms of parent classid + filter handle + match handle must
> be unique per interface. Thoughts? 

I think all you need really is to say "this match starts at IP" i.e such
a definition is global.
handles per rule already exist - and you can actually specify them when
installing a rule. Are those insufficient?

> > Sounds good to me since we have a new sel.
> > It may endup being tricky to be both fast and backward compat; but we'll
> > see what fun awaits when you start coding.
> 
> I started developing concrete thoughts. The current u32 match could be
> made a generic match just like meta which would give us a u32 w/o hashtables
> on a always-true classifier. The problem arises with exactly those
> hashtables.  u32 uses the same selector for this and furthermore even defines
> stuff like hoff and hmask for this purpose. I have to read up again to
> understand the hashing in full detail but this is the only issue I see that
> we might face.
> 

Why not make the always-true to be an extended match? actually a u32
match of 0 0 is always true. Those hashes are quiet tricky/flexible;
i would rather we clone u32 and call it something else then speacilize
it.

> What I have in mind is, something like u32 but much simpler, w/o the
> overhead of creating additional filters for hashing etc. Basically
> this can be the always-true classifier which just implements the
> generic matches tree. And have the existing u32 with the generic
> matches added when hashing is required.
> 

Whip anothe classifier is my opinion. Or write extended matches.

> I planned to write these 2 additional generic matches so far. It's
> pretty simple because I can just take over the code from EGP.
> 
>  KMP: Knuth-Morris-Pratt text search algorithm
>  NByte: Compares any number of bytes against a pattern, very useful
>         for comparing IPv6 addresses instead of creating 4 ANDed
>         u32 matches.

Both sound very appealing. You plan to do them as extended matches,
correct? KMP can be used for something like virus scanning? does it
maintain state?

cheers,
jamal
