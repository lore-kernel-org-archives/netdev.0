From: "Nikolaos D. Bougalis" <nikb@webmaster.com>
Subject: Re: RFC: Established connections hash function
Date: Thu, 22 Mar 2007 13:53:03 -0700
Message-ID: <3C819A2A05834236832EF9E25404D6BE@XEON>
References: <10189ABA61CF4D5AB3881F96C9CACE87@XEON> <20070322155227.GA18557@2ka.mipt.ru> <391F64D0A7C5463CA2D70362E4B3E7EC@XEON> <20070322182156.GB17793@2ka.mipt.ru> <1199CE22A40740D28833A585014BE559@XEON> <20070322195629.GA31182@2ka.mipt.ru>
Reply-To: nikb@webmaster.com
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="koi8-r";
	reply-type=original
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.webmaster.com ([216.152.64.169]:4309 "EHLO
	mail1.webmaster.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750943AbXCVUxP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2007 16:53:15 -0400
Received: from XEON by webmaster.com
	(Cipher TLSv1:RC4-MD5:128) (MDaemon.PRO.v8.1.3.R)
	with ESMTP id md50001457529.msg
	for <netdev@vger.kernel.org>; Thu, 22 Mar 2007 13:53:22 -0800
In-Reply-To: <20070322195629.GA31182@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> We started our discussion a bit wrong - let's start it again, ok? :)

    Fair enough.


> You do not want to read what was written - _if_ we use artificial data,
> then attacker can use it too, so if it is possible to break the system
> with artificial data, then it is possible it will be broken in a real
> life. If we use usual data, then we are ok (although Jenkins with 3
> words is not ok).

    I'm not saying that an attacker cannot use artificial data. Indeed, 
algorithmic complexity attacks are all about 'crafting' artificial data with 
certain properties. So, yes, I absolutely agree that attackers can and do 
use "artificial data."


> >    Be careful here. If the folding makes no difference, it says 
> > something
> > very important about __jhash_mix, and that something goes against the 
> > very
> > thing that you are saying.
>
> Grrr, I think I pointed several times already, that properly distributed
> values do not change distribution after folding. And it can be seen in
> all tests (and in that you pointed too).

    Yes, I agree that the folding will not be a problem _IF_ the values are 
properly distributed -- although in that case, the folding is unnecessary. 
But that the Jenkins distribution didn't change (according to posts you 
made) after folding says that the output of Jenkins is pretty good to begin 
with ;)


> > >>>We can use jhash_2words(laddr, faddr, portpair^inet_ehash_rnd) 
> > >>>though.
> > >>
> > >>   Please explain to me how jhash_2words solves the issue that you 
> > >> claim
> > >>jhash_3words has, when they both use the same underlying bit-mixer?
> > >
> > >$c value is not properly distributed and significanly breaks overall
> > >distribution. Attacker, which controls $c (and it does it by 
> > >controlling
> > >ports), can significantly increase selected hash chains.

    Even if we assume that $c is not properly distributed, using a secret 
cookie and mixing operations from different algebraic groups changes the 
calculus dramatically. It's no longer straight-forward for the attacker to 
generate collisions (as it is with the current function) because the '$c' 
supplied by the attacker is used in conjunction with the secret cookie 
before __jhash_mix thoroughly mixes the inputs to generate a hash.


> >    I've tested the Jenkins hash extensively. I see no evidence of this
> > "improper distribution" that you describe. In fact, about the only 
> > person
> > that I've seen advocate this in the archives of netdev is you, and a lot 
> > of
> > other very smart people disagree with you, so I consider myself to be in
> > good company.
>
> Hmm, I ran tests to select proper hash for netchannel implementation
> (actualy the same as sockets) and showed Jenkin's hash problems - it is
> enough to have only problem to state that there is a problem, doesn't
> it?

    Again, from what I've seen from your other posts, I don't believe you've 
identified any inherent problems with the Jenkins hash.

    But that aside for a moment, surely you will agree that the ability of 
an attacker with a few dozen machines under his control to trivially mount 
an algorithmic complexity attack causing serious performance drops is also a 
problem with the current code and one that must be addressed.


> I will try to decipher phrase 'whatever it is, it's not there'...

    It meant that I saw nothing particularly interesting running the example 
you suggested and looking at the output.


> This thread for example:
> http://marc.info/?t=117057613500001&r=1&w=2

    I went through most of this thread. I don't see an analysis of the 
Jenkins. Am I missing something?


> One your test shows thare are no problems, try that one I propose, which
> can be even created in userspace - you do not want even to get into
> account what I try to say to you.

    I'm not trying to be obnoxious on purpose here, but I don't see the test 
that you are referring to. Could you be more specific?

    -n


