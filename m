From: jamal <hadi@cyberus.ca>
Subject: Re: [PKT_SCHED]: Allow using nfmark as key in U32 classifier.
Date: 28 Dec 2004 20:13:31 -0500
Message-ID: <1104282811.1090.314.camel@jzny.localdomain>
References: <20041228134022.GA32419@postel.suug.ch>
	 <1104242397.1090.94.camel@jzny.localdomain>
	 <20041228161117.GD32419@postel.suug.ch>
	 <1104251817.1090.164.camel@jzny.localdomain>
	 <20041228192603.GE32419@postel.suug.ch>
	 <1104268498.1090.254.camel@jzny.localdomain>
	 <20041228221021.GF32419@postel.suug.ch>
	 <1104275197.1100.276.camel@jzny.localdomain>
	 <20041228231916.GG32419@postel.suug.ch>
	 <1104277165.1100.291.camel@jzny.localdomain>
	 <20041229000928.GH32419@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041229000928.GH32419@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2004-12-28 at 19:09, Thomas Graf wrote:
> * jamal <1104277165.1100.291.camel@jzny.localdomain> 2004-12-28 18:39
> > On Tue, 2004-12-28 at 18:19, Thomas Graf wrote:
> > match u32 ..
> > ematch string "Thomas" ...
> > match u32 ...
> > ematch meta tcindex ..
> 
> Yes but the only avantage of this is that a u32 match can be
> made dependant on a ematch. Is this really worth special
> handling? It requires special handling not needed for any
> of the other classifiers.
> 
> I understand your point but don't agree at the moment. I
> might change my mind tomorrow ;->

no problem ;-> I think the effort is the same as in doing it the other
way - only result is more sophisticated. I havent investigated the other
classifiers - u32 tends to be more complex, so solving it on u32 solves
all the others typically.

> > I dont wanna go into details of whether we could actually make the new
> > keys do more than just strict AND from left to right - but you can see
> > the potential to "fix" this if we are defining a new key ;->
> 
> We should rather do it on cls_api level, unfortunantely it's not that
> simple but the current status of having one classifier kind per prio and
> no way to interconnect them must be changed somewhen. 
> 

Remember two levels: 
1) the classifier logical expressions (u32 and rsvp for example) - those
belong to cls api.

if u32 match .. ... AND rsvp ... OR route ...
evaluation is left to right with some brute logical OR and ANDs via the
continue and reclassify codes.

2) This issue is at a the single classifier/filter level, so its fair to
push that into the classifier logic. an extended match cannot live by
itself. Its parasitic on a real classifier - so the scope MUST be
restricted to classifier as a matter of fact.

> > Ok, the logical expressions are the tricky part. But refer to what i am
> > saying above. You still need to be backward compatible. But for the new
> > keys you could go onto the adventorous side. I havent given the logical
> > expressions much thought but i will in the background
> 
> Implementing logical expressions directly into u32 would be bad but
> we could have u32 hold a expression tree rather than the ematch
> directly which means you could do
> 
> match u32 ..
> (ematch meta nfmark .. or string "...")
> match u32 ..
> 

Or you could have:
match u32 OR
(ematch meta nfmark .. or string "...")
match u32 ..

Recall, the opportunity to do more in terms of logical expressions within u32 
exists because we can introduce more interesting keys ...

Anyways, I am going to introduce extended actions. I need to write a few
stupid little actions not worth the whole API (such as a checksum
validator/recomputer which i need to follow the pedit action for
stateless NAT). It would use exactly teh same interleaving logic as what
weve discussed.
I dont know where you and Patrick are with the code but it think it
would be safe for me to work off 2610-bk1. Tommorow i am working on some
e1000 stuff - but day after i should be able to touch the action code. 

cheers,
jamal
