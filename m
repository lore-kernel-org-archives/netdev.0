From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH 02/27] drivers/net: fix sparse warnings: make do-while a compound statement
Date: Wed, 24 Dec 2008 00:18:46 +0100
Message-ID: <m3hc4usco9.fsf@maximus.localdomain>
References: <20081222191259.11807.53190.stgit@vmbox.hanneseder.net>
	<20081222191507.11807.50794.stgit@vmbox.hanneseder.net>
	<m3hc4voo2a.fsf@maximus.localdomain>
	<a01a16b50812221544x45c3559ap808ac0095ee8f01@mail.gmail.com>
	<m3ocz2ua3w.fsf@maximus.localdomain> <1230053186.1447.9.camel@brick>
	<m3k59qssix.fsf@maximus.localdomain>
	<alpine.LFD.2.00.0812231008350.3535@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Harvey Harrison <harvey.harrison@gmail.com>,
	=?utf-8?B?SMOla29uIEzDuHZkYWw=?= <hlovdal@gmail.com>,
	Hannes Eder <hannes@hanneseder.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:57119 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751791AbYLWXSs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Dec 2008 18:18:48 -0500
In-Reply-To: <alpine.LFD.2.00.0812231008350.3535@localhost.localdomain> (Linus Torvalds's message of "Tue\, 23 Dec 2008 10\:08\:50 -0800 \(PST\)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Linus Torvalds <torvalds@linux-foundation.org> writes:

> It's more than that. I added the check after some person who had been 
> programming the kernel (and thus was supposedly fluent in C) literally 
> could not parse a macro that had "do x while (y)" in it.

A literally that simple macro, or a complicated one?


I'm all for using brackets when there is / could be some possibility
of increasing code readability.

E.g. I always use parentheses in a nested if-if, because

	if (x)
		if (y)
			a;
		else
			c;

may be confusing, especially if formatted differently.

	if (x)
		a;
	else if (y)
		b;
	etc.

is simple and unambiguous and I don't put the braces.

So is a case like
	do
		x;
	while (y);
It can't be made more clear with brackets.

IOW: improving the style is great. Changing it only to silence some
tool is not.

> Another example of this is "sizeof". The kernel universally (I hope) has 
> parenthesis around the sizeof argument, even though it's clearly not 
> required by the C language. 
>
> It's a coding standard.

Right, but they (at least for me) make it more readable.
kmalloc(sizeof i) just doesn't look good, the operator looks like
a variable name.

But there is this return statement. Some people tend to write
return (x); I simply write return x;
It's clear, and so is a simple do-while.

> And quite frankly, anybody who works on gcc has no place complaining about 
> sparse coding standard warnings. They are a _hell_ of a lot better than 
> some of the really crazy warnings gcc spews out with "-W". At least the 
> sparse warnings you can make go away while making the code more 
> understandable. Some of the -W warnings are unfixable without breaking the 
> source code.

:-)

BTW I think I may use sparse differently.
I can see false gcc warnings every time the project is being built.
OTOH I run sparse only when I have some (almost) completed project
(a patch, a driver etc). I make sure the remaining sparse warnings are
(from my POV) invalid and it won't spew them on next build again.
-- 
Krzysztof Halasa
