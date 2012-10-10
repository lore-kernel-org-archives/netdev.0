From: Peter Senna Tschudin <peter.senna@gmail.com>
Subject: Re: [PATCH 19/20] drivers/net/ethernet/marvell/skge.c: fix error
 return code
Date: Wed, 10 Oct 2012 19:08:02 +0200
Message-ID: <CA+MoWDp8Y0tJoBbz0nxH3Y7J0ur3TJm-dO9OM5BZVBKcbS9TpA@mail.gmail.com>
References: <CA+MoWDp=_F9opJbVkv9sDsmoykm7MTUZwRVumKCB0ZqDwD6NoQ@mail.gmail.com>
	<20121004.142335.1467206545795435493.davem@davemloft.net>
	<CA+MoWDqBF5bdQYBaUmpB99Q=YcHYcUxi8Ffo3x4s0B+pmomb+Q@mail.gmail.com>
	<20121004.145419.1859367129463136197.davem@davemloft.net>
	<1349395795.2008.26.camel@joe-AO722>
	<alpine.DEB.2.02.1210050712590.1958@localhost6.localdomain6>
	<1349422595.2008.55.camel@joe-AO722>
	<alpine.DEB.2.02.1210051003120.1958@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Joe Perches <joe@perches.com>, David Miller <davem@davemloft.net>,
	shemminger@vyatta.com, mlindner@marvell.com,
	kernel-janitors@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Julia Lawall <julia.lawall@lip6.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.02.1210051003120.1958@localhost6.localdomain6>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen and David,

I've sent V2 of the patches and they were all accepted. Thank you.

I've made a template for the commit message, and then copy and paste
function names from the code. Something like:

-- // --
The function sky2_probe() return 0 for success and negative value
for most of its internal tests failures. There are two exceptions
that are error cases going to err_out*:. For this two cases, the
function abort its success execution path, but returns non negative
value, making it dificult for a caller function to notice the error.

This patch fixes the error cases that do not return negative values.

This was found by Coccinelle, but the code change was made by hand.
This patch is not robot generated.
...
--//--

How useful it was to have the function names when you were analyzing
the patches? It took me a lot of time to modify the template by copy
and paste, check if it is correct, then commit. I have some other
similar patches to submit and I wonder if having the function names in
the commit message helped you.

Thank you,

Peter


On Fri, Oct 5, 2012 at 10:08 AM, Julia Lawall <julia.lawall@lip6.fr> wrote:
> On Fri, 5 Oct 2012, Joe Perches wrote:
>
>> On Fri, 2012-10-05 at 07:22 +0200, Julia Lawall wrote:
>>>
>>> A tool was used to find a potential problem, and then Peter
>>> studied the code to see what fix was appropriate.
>>
>>
>> Hi Julia.
>>
>> Was it true that a static analysis tool found the original
>> potential issue?  If so, what tool was it?
>
>
> In the very beginning, I think that I found the problem in a patch when
> looking at patches that contain oopses.
>
> From that I wrote a Coccinelle rule.  As Peter showed, the rule just
> produces a list of line numbers.  The fix cannot easily be automated,
> because there are many cases where 0 is a valid error value.  Some
> functions, for example, have their error value as a nonpositive integer.
>
>
>> But wasn't the scripted fix applied to the rest of the tree
>> robotically?
>
>
> No.  Peter studied each case and considered what should be done, and then
> did that.  I guess a potentially bad fix could have been applied
> automatically and then cleaned up manually, but considering the number of
> cases where the fix would be wrong, that seem like a bad idea.  Also one
> might want to adapt a bit to local conventions about where the
> initialization should be added.
>
> julia



-- 
Peter
