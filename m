From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH 19/20] drivers/net/ethernet/marvell/skge.c: fix error
 return code
Date: Fri, 5 Oct 2012 10:08:47 +0200 (CEST)
Message-ID: <alpine.DEB.2.02.1210051003120.1958@localhost6.localdomain6>
References: <CA+MoWDp=_F9opJbVkv9sDsmoykm7MTUZwRVumKCB0ZqDwD6NoQ@mail.gmail.com>  <20121004.142335.1467206545795435493.davem@davemloft.net>  <CA+MoWDqBF5bdQYBaUmpB99Q=YcHYcUxi8Ffo3x4s0B+pmomb+Q@mail.gmail.com>  <20121004.145419.1859367129463136197.davem@davemloft.net>
  <1349395795.2008.26.camel@joe-AO722>  <alpine.DEB.2.02.1210050712590.1958@localhost6.localdomain6> <1349422595.2008.55.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Julia Lawall <julia.lawall@lip6.fr>,
	David Miller <davem@davemloft.net>, peter.senna@gmail.com,
	shemminger@vyatta.com, mlindner@marvell.com,
	kernel-janitors@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1349422595.2008.55.camel@joe-AO722>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 5 Oct 2012, Joe Perches wrote:

> On Fri, 2012-10-05 at 07:22 +0200, Julia Lawall wrote:
>> A tool was used to find a potential problem, and then Peter
>> studied the code to see what fix was appropriate.
>
> Hi Julia.
>
> Was it true that a static analysis tool found the original
> potential issue?  If so, what tool was it?

In the very beginning, I think that I found the problem in a patch when 
looking at patches that contain oopses.

>From that I wrote a Coccinelle rule.  As Peter showed, the rule just 
produces a list of line numbers.  The fix cannot easily be automated, 
because there are many cases where 0 is a valid error value.  Some 
functions, for example, have their error value as a nonpositive integer.

> But wasn't the scripted fix applied to the rest of the tree
> robotically?

No.  Peter studied each case and considered what should be done, and then 
did that.  I guess a potentially bad fix could have been applied 
automatically and then cleaned up manually, but considering the number of 
cases where the fix would be wrong, that seem like a bad idea.  Also one 
might want to adapt a bit to local conventions about where the 
initialization should be added.

julia
