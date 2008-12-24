From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH 02/27] drivers/net: fix sparse warnings: make do-while a compound statement
Date: Wed, 24 Dec 2008 03:03:50 +0100
Message-ID: <m3myemqqgp.fsf@maximus.localdomain>
References: <20081222191259.11807.53190.stgit@vmbox.hanneseder.net>
	<20081222191507.11807.50794.stgit@vmbox.hanneseder.net>
	<m3hc4voo2a.fsf@maximus.localdomain>
	<a01a16b50812221544x45c3559ap808ac0095ee8f01@mail.gmail.com>
	<m3ocz2ua3w.fsf@maximus.localdomain> <1230053186.1447.9.camel@brick>
	<m3k59qssix.fsf@maximus.localdomain>
	<alpine.LFD.2.00.0812231008350.3535@localhost.localdomain>
	<m3hc4usco9.fsf@maximus.localdomain>
	<alpine.LFD.2.00.0812231529030.3535@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Harvey Harrison <harvey.harrison@gmail.com>,
	=?utf-8?B?SMOla29uIEzDuHZkYWw=?= <hlovdal@gmail.com>,
	Hannes Eder <hannes@hanneseder.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:53531 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751577AbYLXCDx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Dec 2008 21:03:53 -0500
In-Reply-To: <alpine.LFD.2.00.0812231529030.3535@localhost.localdomain> (Linus Torvalds's message of "Tue\, 23 Dec 2008 15\:38\:02 -0800 \(PST\)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Linus Torvalds <torvalds@linux-foundation.org> writes:

> Oh yes it can. People look at that, and it's so uncommon that they 
> literally believe it is a mis-indent.

People learn, or should, through the life :-)

I'm not sure being common or less common does matter here much.

OTOH I think it's pretty common. Approx as common as while (x) y is,
isn't it?

Except in macros: do-while(0) is commonly used in macros because it
"eats" the semicolon.

(do { xxx; yyy; zzz } while (0) is also quite common instead of "goto"
to add multiple exits from a long block).

> Your example with nested if-statements are totally pointless, because you 
> didn't even apparently understand my comment about "while()" having two 
> totally different meanings (which is not true of "if()"), nor realize the 
> importance of how common something is.

Only apparently. If there is no ambiguity, there is no problem, the
double meaning does not seem relevant.

You tell me that

	do
		expr;
	while (condition);

(with precisely this formatting) can be unclear?

Or you say

	do {
		expr;
	} while (condition);

is better? If it is, then certainly not for me.


Now: are we going to write {} because you say so, even if it makes the
code worse? Or should we rather aim at improving the code, even if
only a bit? (I admit that, IMO, the second example is worse = less
readable, but only a small bit).

> Sorry, you're wrong. It's not changed to silence some tool.

Come on, you have it plain in the subject - "fix sparse warnings".
If it was "improve obscure notation" I wouldn't say a word.

> And I agree with you. "sizeof i" doesn't look good. It's uncommon, and 
> doesn't match peoples expectations.

But it doesn't matter if it's common or not. It doesn't look good and
THIS IS WHY it's uncommon/nonexistent. Not the other way around.

There are many uncommon things in a project like a Linux kernel. There
are some macros which take me a while :-) to understand and they
thankfully don't spew warnings.

> Another example of "common vs non-common" is this:
>
> 	if (0 <= x)
> 		do something..
>
> is something that crazy people do (sadly, one of the crazy people taught 
> the git maintainer C programming, so now even sane people do it). It's 
> crazy because it's uncommon, which means that most people have to think 
> about it A LOT MORE than about
>
> 	if (x >= 0)
> 		do something..

No. It's crazy not because it's uncommon, but because this is how we
have been taught in school.

I don't know reasons for "0 >= x" but I know one for
	if (0 == x)
		do something..

It's because people sometimes write "=" instead of "==" and "0 = x"
doesn't make sense to gcc. I think it's not a valid reason, and
(unless you use (()) which is IMHO also crazy) gcc will warn about
if (x = 0) (though I think the warning is stupid and "if (a = b)"
is a valid usage if a and b are short).

It's simple: one has to see the difference between if (x = 0) vs
if (x == 0), there is no way around it. if (0 >= x), I don't know.

> Can you see the argument? Doing things the common way is important, 
> because it allows people to see what they mean without having to think 
> about it. They just scan it, and the meaning is clear.

Then I must be different. Things are clear to me if they are clear,
even if they are uncommon. And common things aren't necessarily clear.
Hmm, I should have expected something like that.

> And that's why "do while" without braces is bad. If you scan it quickly on 
> its own, you may well end up just seeing the
>
> 	while (x);
>
> part, and get confused ("oh, a delay loop").

Nope.
It raises a red flag in my head immediately. We don't do such busy
loops generally, and if we do, I would write it as:

	while (x)
		;

> But if you see
>
> 	} while (x);
>
> you aren't confused, because the latter one is clearly an ending condition 
> of a do-while loop, IN A WAY THAT THE FIRST ONE IS NOT!
>
> See?

No. I must be different.

> do-while is very special, because as mentioned, "while" is a really magic 
> C keyword that has two TOTALLY DIFFERENT meanings.

Probably. I just don't see it.

For me, every code fragment is different, and a program like sparse
can't even come close to know what's clear for me and what is not.

I use sparse as a great help - but only that, a help.
-- 
Krzysztof Halasa
