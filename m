From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 02/27] drivers/net: fix sparse warnings: make do-while
 a compound statement
Date: Tue, 23 Dec 2008 15:38:02 -0800 (PST)
Message-ID: <alpine.LFD.2.00.0812231529030.3535@localhost.localdomain>
References: <20081222191259.11807.53190.stgit@vmbox.hanneseder.net> <20081222191507.11807.50794.stgit@vmbox.hanneseder.net> <m3hc4voo2a.fsf@maximus.localdomain> <a01a16b50812221544x45c3559ap808ac0095ee8f01@mail.gmail.com> <m3ocz2ua3w.fsf@maximus.localdomain>
 <1230053186.1447.9.camel@brick> <m3k59qssix.fsf@maximus.localdomain> <alpine.LFD.2.00.0812231008350.3535@localhost.localdomain> <m3hc4usco9.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Harvey Harrison <harvey.harrison@gmail.com>,
	=?ISO-8859-15?Q?H=E5kon_L=F8vdal?= <hlovdal@gmail.com>,
	Hannes Eder <hannes@hanneseder.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:55313 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751952AbYLWXiJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Dec 2008 18:38:09 -0500
In-Reply-To: <m3hc4usco9.fsf@maximus.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Wed, 24 Dec 2008, Krzysztof Halasa wrote:
> 
> So is a case like
> 	do
> 		x;
> 	while (y);
> It can't be made more clear with brackets.

Oh yes it can. People look at that, and it's so uncommon that they 
literally believe it is a mis-indent.

Your example with nested if-statements are totally pointless, because you 
didn't even apparently understand my comment about "while()" having two 
totally different meanings (which is not true of "if()"), nor realize the 
importance of how common something is.

Common patterns become things that people take for granted and don't have 
any trouble with. In contrast, do-while without braces is _extremely_ 
uncommon.

> IOW: improving the style is great. Changing it only to silence some
> tool is not.

Sorry, you're wrong. It's not changed to silence some tool. THIS IS THE 
KERNEL CODING STYLE. 

I don't care one whit about your personal coding style. The kernel has 
brances. End of discussion. sparse complains about lack of them. 
Comprende?

> Right, but they (at least for me) make it more readable.

I don't care.

> kmalloc(sizeof i) just doesn't look good, the operator looks like
> a variable name.

And I agree with you. "sizeof i" doesn't look good. It's uncommon, and 
doesn't match peoples expectations.

> But there is this return statement. Some people tend to write
> return (x); I simply write return x;

I do to. And it's the common thing to do, and only totally confused people 
think that 'return' is a somehow remotely like a "function" of its 
arguments (the way 'sizeof' is - sizeof _is_ a function of its arguments, 
albeit a very rare one).

> It's clear, and so is a simple do-while.

No. "return x;" is clear because it's the common thing, which means that 
peopel are good at reading it.

Another example of "common vs non-common" is this:

	if (0 <= x)
		do something..

is something that crazy people do (sadly, one of the crazy people taught 
the git maintainer C programming, so now even sane people do it). It's 
crazy because it's uncommon, which means that most people have to think 
about it A LOT MORE than about

	if (x >= 0)
		do something..

even though technically both are obviously EXACTLY THE SAME THING.

Can you see the argument? Doing things the common way is important, 
because it allows people to see what they mean without having to think 
about it. They just scan it, and the meaning is clear.

And that's why "do while" without braces is bad. If you scan it quickly on 
its own, you may well end up just seeing the

	while (x);

part, and get confused ("oh, a delay loop"). But if you see

	} while (x);

you aren't confused, because the latter one is clearly an ending condition 
of a do-while loop, IN A WAY THAT THE FIRST ONE IS NOT!

See?

do-while is very special, because as mentioned, "while" is a really magic 
C keyword that has two TOTALLY DIFFERENT meanings. Don't make people look 
for the "do".

		Linus
