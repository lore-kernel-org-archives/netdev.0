From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] High Performance Packet Classifiction for tc framework
Date: 11 Aug 2003 22:57:08 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1060657028.1028.79.camel@jzny.localdomain>
References: <200307141045.40999.nf@hipac.org>
	 <1058328537.1797.24.camel@jzny.localdomain>  <3F16A0E5.1080007@hipac.org>
	 <1059934468.1103.41.camel@jzny.localdomain>  <3F2E5CD6.4030500@hipac.org>
	 <1060012260.1103.380.camel@jzny.localdomain>  <3F302E04.1090503@hipac.org>
	 <1060286331.1025.73.camel@jzny.localdomain>  <3F381B3E.6080807@hipac.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Michael Bellion and Thomas Heinz <nf@hipac.org>
In-Reply-To: <3F381B3E.6080807@hipac.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

On Mon, 2003-08-11 at 18:39, Michael Bellion and Thomas Heinz wrote:

> > It was very close ;-> The guy looked motivated i felt scared for a while
> > that he will be asking a lot of questions. Then i never heard about it
> > again ;-> I think he left town too. 
> 
> Too bad, you should have told the guy about all the fame
> and glory ;-)
> 

Some fires scare even brave firemen. This was a brave fireman until he
saw the fire ;->

[..]

> 
> This is a fundamental issue related to the use of hashes in this
> context. It shows that it is _impossible_ to create a hash which
> meets the requirement of O(1) rules per bucket in the setting
> described above regardless how clever you choose the hash function.
> 
> What do you think about it? Do you agree?
> 

I have to go back and read the theory again to fully comprehend it but
intutively you are right. I claim that if you knew your input well then
you could construct a hash which will closely approach perfect hashing.
So if i was to use the example you gave me earlier i could approximate a
o(1) hash. u32 allows me to do so once i know how things will look like.
Of course i have to do that mnaully with a pencil and paper.



> 
> >>BTW, this approach can be extended to 2 or more dimensions
> >>where the hash function for each hash has to meet the
> >>requirement. Of course this information is not very helpful
> >>since the problem of defining appropriate hash functions
> >>remains ;)
> > 
> > Is that problem even solvable?
> 
> Well, one could argue that the _problem_ is not precisely
> defined to answer this question since "easily (= fast)
> computable hash function" is rather spongy.
> 
> Ignoring the "fast computable" requirement, the problem
> is solvable simply because the hash function is finite ...
> but again this does not help a bit ;-)
> 
> So, do you agree that it is _impossible_ to express arbitrary
> access lists using the hash tree approach if each hash bucket
> is required to hold O(1) rules?
> [You already agreed that this requirement is needed for the
>   tree of hashes to perform optimally.]
> 

yes. But note the caveat i put above on knowing the input and being able
to manually use a pencil to map out the hash. Now automate the pencil
and paper and let some cpu analyse the traffic patterns as well as
adjust the hashes ... maybe a thesis for someone.

> > This is why i was wondering how fast your instertions and deletions are.
> > Seems to me you will have to sort the rules everytime.
> 
> No, there is no sorting of rules involved. Each rule insert
> operation inserts the native matches of the rule into the
> (dim)tree.
> 

I will have to cathup with you at some point - i think i understand what
you mean.

> > Dont you think this "dynamic adjustment" is unnecessary. Essentially you
> > enforce a model where every rule is a different priority.
> 
> Well, we consider the model beneficial for the user.
> First of all the requirement is also present in the
> classical PCP definition ;) and secondly it supports
> dynamic rulesets better because using static priorities
> you ran into the problem of redefining a lot of prios
> manually sooner or later.
> 

well, with the iptables scheme at least you need to know where to insert
the rules; so theres some manual labor involved there as well ;->
Out of curiosity with such a model how do you define a default rule?
In the prio model(and tc), you can have a default catchall rule in the
lowest priority, this way should higher prios fail this will catchall.


[..]

> > 
> > I am not sure i understood the part about ignoring tcf_result.
> 
> If there would be no tcf_result then classifiers are
> simply matches, e.g. like iptables matches. They don't have
> an action associated with them. In iptables, from a technical
> viewpoint you could say that a target is basically the same
> as a match with an action attached to it.
> 

Ok, i see your point, so you are saying that a tcf_result is infact a
hardcoded action which should probably be called "setclassid".
Interesting thought.

[..]

> > But could you not have
> > the filters repeat the same classid for every filter? 
> 
> Each rule can only have one action or return "value"
> attached to it so if we want to use embedded classifiers
> (as matches) their classid (= action) must be ignored.

you want the "continue" action essentially.

> The reason why we want to have several non-native
> matches in one rule is to allow the expression of a
> conjunction of these matches. This is not possible using
> several rules.

I think i finally see your point. Yes, this could be an improvement that
could be made to tc. Infact you have motivated me to write a
"setclassid" action which will override the classid defined otherwise.

cheers,
jamal
