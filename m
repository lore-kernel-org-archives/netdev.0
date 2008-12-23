From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 02/27] drivers/net: fix sparse warnings: make do-while
 a compound statement
Date: Tue, 23 Dec 2008 10:08:50 -0800 (PST)
Message-ID: <alpine.LFD.2.00.0812231008350.3535@localhost.localdomain>
References: <20081222191259.11807.53190.stgit@vmbox.hanneseder.net> <20081222191507.11807.50794.stgit@vmbox.hanneseder.net> <m3hc4voo2a.fsf@maximus.localdomain> <a01a16b50812221544x45c3559ap808ac0095ee8f01@mail.gmail.com> <m3ocz2ua3w.fsf@maximus.localdomain>
 <1230053186.1447.9.camel@brick> <m3k59qssix.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Harvey Harrison <harvey.harrison@gmail.com>,
	=?ISO-8859-15?Q?H=E5kon_L=F8vdal?= <hlovdal@gmail.com>,
	Hannes Eder <hannes@hanneseder.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:48003 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750986AbYLWSJb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Dec 2008 13:09:31 -0500
In-Reply-To: <m3k59qssix.fsf@maximus.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 23 Dec 2008, Krzysztof Halasa wrote:

> Harvey Harrison <harvey.harrison@gmail.com> writes:
> 
> >> There are many ways to make the code more merge friendly at a cost of
> >> readability. Hope we don't go this way.
> >
> > Linus himself added that particular warning to sparse...may want to check
> > with him the reason for it.
> 
> Once again, this is a personal thing, and a harmless one.

It's more than that. I added the check after some person who had been 
programming the kernel (and thus was supposedly fluent in C) literally 
could not parse a macro that had "do x while (y)" in it.

Why? Because it's so uncommon, and because "while (y)" on its own means 
something totally different.

So the syntactic sugar to _always_ have do-while loops have that brace is 
a way to avoid one of the rather few places where the C language has 
syntax that is very context-dependent.

Another example of this is "sizeof". The kernel universally (I hope) has 
parenthesis around the sizeof argument, even though it's clearly not 
required by the C language. 

It's a coding standard. 

And quite frankly, anybody who works on gcc has no place complaining about 
sparse coding standard warnings. They are a _hell_ of a lot better than 
some of the really crazy warnings gcc spews out with "-W". At least the 
sparse warnings you can make go away while making the code more 
understandable. Some of the -W warnings are unfixable without breaking the 
source code.

		Linus
