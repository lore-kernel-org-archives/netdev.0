From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PKT_SCHED]: Allow using nfmark as key in U32 classifier.
Date: Thu, 30 Dec 2004 18:43:13 +0100
Message-ID: <20041230174313.GB32419@postel.suug.ch>
References: <20041228221021.GF32419@postel.suug.ch> <1104275197.1100.276.camel@jzny.localdomain> <20041228231916.GG32419@postel.suug.ch> <1104277165.1100.291.camel@jzny.localdomain> <20041229000928.GH32419@postel.suug.ch> <1104282811.1090.314.camel@jzny.localdomain> <20041229124842.GI32419@postel.suug.ch> <1104330054.1089.329.camel@jzny.localdomain> <20041229150140.GJ32419@postel.suug.ch> <1104335620.1025.22.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1104335620.1025.22.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1104335620.1025.22.camel@jzny.localdomain> 2004-12-29 10:53
> > > Also in the case of u32 (to take this opportunity) i would like to stash
> > > state inot a 16 bit ID to help in pretty printing the matches.
> > 
> > Not sure what you mean. Which "state"?
> > 
> 
> One example of what state you could store:
> In the case where i enter something readable in english, the display
> back is raw; 
> example:
> match ip src 10.0.0.210/32
> gets displayed as: match 0a0000d2/ffffffff at 12
> And a lot of times its tricky to find exactly what "at 12" means.
> 
> If i store some ID that would tell me "IP" when i dump then i can pretty
> print it in english in user space using ip_print().

Understood, we could store a map in userspace mapping those IDs to
pretty english match descriptions. I think avoiding to hardcode those
ids but rather just hold it for userspace is the best thing. OTOH, if
we give unique ids to matches we can use it instead of a separate ID.
Unique in terms of parent classid + filter handle + match handle must
be unique per interface. Thoughts? 

> Sounds good to me since we have a new sel.
> It may endup being tricky to be both fast and backward compat; but we'll
> see what fun awaits when you start coding.

I started developing concrete thoughts. The current u32 match could be
made a generic match just like meta which would give us a u32 w/o hashtables
on a always-true classifier. The problem arises with exactly those
hashtables.  u32 uses the same selector for this and furthermore even defines
stuff like hoff and hmask for this purpose. I have to read up again to
understand the hashing in full detail but this is the only issue I see that
we might face.

What I have in mind is, something like u32 but much simpler, w/o the
overhead of creating additional filters for hashing etc. Basically
this can be the always-true classifier which just implements the
generic matches tree. And have the existing u32 with the generic
matches added when hashing is required.

I planned to write these 2 additional generic matches so far. It's
pretty simple because I can just take over the code from EGP.

 KMP: Knuth-Morris-Pratt text search algorithm
 NByte: Compares any number of bytes against a pattern, very useful
        for comparing IPv6 addresses instead of creating 4 ANDed
        u32 matches.
