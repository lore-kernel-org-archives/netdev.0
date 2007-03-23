From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: RFC: Established connections hash function
Date: Fri, 23 Mar 2007 10:52:25 +0300
Message-ID: <20070323075225.GA29991@2ka.mipt.ru>
References: <10189ABA61CF4D5AB3881F96C9CACE87@XEON> <20070322155227.GA18557@2ka.mipt.ru> <391F64D0A7C5463CA2D70362E4B3E7EC@XEON> <20070322182156.GB17793@2ka.mipt.ru> <1199CE22A40740D28833A585014BE559@XEON> <20070322195629.GA31182@2ka.mipt.ru> <3C819A2A05834236832EF9E25404D6BE@XEON>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org
To: "Nikolaos D. Bougalis" <nikb@webmaster.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:38789 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752674AbXCWHwa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Mar 2007 03:52:30 -0400
Content-Disposition: inline
In-Reply-To: <3C819A2A05834236832EF9E25404D6BE@XEON>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 22, 2007 at 01:53:03PM -0700, Nikolaos D. Bougalis (nikb@webmaster.com) wrote:
> >Grrr, I think I pointed several times already, that properly distributed
> >values do not change distribution after folding. And it can be seen in
> >all tests (and in that you pointed too).
> 
>    Yes, I agree that the folding will not be a problem _IF_ the values are 
> properly distributed -- although in that case, the folding is unnecessary. 
> But that the Jenkins distribution didn't change (according to posts you 
> made) after folding says that the output of Jenkins is pretty good to begin 
> with ;)

In _some_ cases, but not in all.
 
> >> >>>We can use jhash_2words(laddr, faddr, portpair^inet_ehash_rnd) 
> >> >>>though.
> >> >>
> >> >>   Please explain to me how jhash_2words solves the issue that you 
> >> >> claim
> >> >>jhash_3words has, when they both use the same underlying bit-mixer?
> >> >
> >> >$c value is not properly distributed and significanly breaks overall
> >> >distribution. Attacker, which controls $c (and it does it by 
> >> >controlling
> >> >ports), can significantly increase selected hash chains.
> 
>    Even if we assume that $c is not properly distributed, using a secret 
> cookie and mixing operations from different algebraic groups changes the 
> calculus dramatically. It's no longer straight-forward for the attacker to 
> generate collisions (as it is with the current function) because the '$c' 
> supplied by the attacker is used in conjunction with the secret cookie 
> before __jhash_mix thoroughly mixes the inputs to generate a hash.

With XOR hash attacker can predict end result easily, with jenkins it
can not (easily), but jenkins distribution itself (even for usual data) 
results in too long chains - there are two problems:
1. easily predicted result
2. broken distribution

Xor hash has problems with first one, Jenkins (in some cases) with
second.
 
> >>    I've tested the Jenkins hash extensively. I see no evidence of this
> >> "improper distribution" that you describe. In fact, about the only 
> >> person
> >> that I've seen advocate this in the archives of netdev is you, and a lot 
> >> of
> >> other very smart people disagree with you, so I consider myself to be in
> >> good company.
> >
> >Hmm, I ran tests to select proper hash for netchannel implementation
> >(actualy the same as sockets) and showed Jenkin's hash problems - it is
> >enough to have only problem to state that there is a problem, doesn't
> >it?
> 
>    Again, from what I've seen from your other posts, I don't believe you've 
> identified any inherent problems with the Jenkins hash.
> 
>    But that aside for a moment, surely you will agree that the ability of 
> an attacker with a few dozen machines under his control to trivially mount 
> an algorithmic complexity attack causing serious performance drops is also 
> a problem with the current code and one that must be addressed.

Please refer to above two problems - Jenkins hash does not have problem
with easy end result detection, instead if has distribution problem.
Which means that attacker should not guess hash chains, it should
provide special crafted input and distribution will be shifted to the
higher levels.
 
> >I will try to decipher phrase 'whatever it is, it's not there'...
> 
>    It meant that I saw nothing particularly interesting running the example 
> you suggested and looking at the output.
> 
> 
> >This thread for example:
> >http://marc.info/?t=117057613500001&r=1&w=2
> 
>    I went through most of this thread. I don't see an analysis of the 
> Jenkins. Am I missing something?

There is no full analysis, I just posted results I found when selected
hash for different projects with similar to sockets background.
 
> >One your test shows thare are no problems, try that one I propose, which
> >can be even created in userspace - you do not want even to get into
> >account what I try to say to you.
> 
>    I'm not trying to be obnoxious on purpose here, but I don't see the test 
> that you are referring to. Could you be more specific?

http://marc.info/?l=linux-netdev&m=117199140430104&q=p5

>    -n
-- 
	Evgeniy Polyakov
