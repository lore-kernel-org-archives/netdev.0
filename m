From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH 19/20] drivers/net/ethernet/marvell/skge.c: fix error
 return code
Date: Fri, 5 Oct 2012 07:22:03 +0200 (CEST)
Message-ID: <alpine.DEB.2.02.1210050712590.1958@localhost6.localdomain6>
References: <CA+MoWDp=_F9opJbVkv9sDsmoykm7MTUZwRVumKCB0ZqDwD6NoQ@mail.gmail.com>  <20121004.142335.1467206545795435493.davem@davemloft.net>  <CA+MoWDqBF5bdQYBaUmpB99Q=YcHYcUxi8Ffo3x4s0B+pmomb+Q@mail.gmail.com>  <20121004.145419.1859367129463136197.davem@davemloft.net>
 <1349395795.2008.26.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: David Miller <davem@davemloft.net>, peter.senna@gmail.com,
	shemminger@vyatta.com, mlindner@marvell.com,
	kernel-janitors@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1349395795.2008.26.camel@joe-AO722>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 4 Oct 2012, Joe Perches wrote:

> On Thu, 2012-10-04 at 14:54 -0400, David Miller wrote:
>> From: Peter Senna Tschudin <peter.senna@gmail.com>
>>> On Thu, Oct 4, 2012 at 8:23 PM, David Miller <davem@davemloft.net> wrote:
>>>> We want to know the implications of the bug being fixed.
>>>> Does it potentially cause an OOPS?  Bad reference counting and thus
>>>> potential leaks or early frees?
>>>>
>>>> You have to analyze the implications and ramifications of the bug
>>>> being fixed.  We need that information.
>
> You are asking for deeper level analysis that may not
> be reasonably possible from the robotic patch fixed
> by a robotic piece of a bit of code correction via a
> static analysis.

As Peter pointed out, it is not even a robotic fix, if robotic means 
literally that it was done by a robot.  A tool was used to find a 
potential problem, and then Peter studied the code to see what fix was 
appropriate.

In this case, finding out the impact, requires looking up the call chain 
in all directions to find out what the callers do with the returned value. 
And understanding the likely impact along the way.  Often the call chain 
involves function pointers.  This is all possible to do.  And perhaps it 
would be even more helpful to the consumers of the patch than just having 
the problem fixed.  But the fact remains that at other places in the 
function, someone thought it was useful to return an error code, so in the 
place where the error code return is missing, it seems like a useful fault 
to fix, whether it has an impact now or might have one later.  The main 
human analysis required to generate the patch is to be convinced that the 
given return path really represents an error condition and that the 
function normally returns the specified kind of value in that case.  If 
there is some way in which these points are unclear, then the commit
message should certainly explain the reasoning that was used.

julia

>
>>>> It's just "bad error code, this is the script that fixed it, kthx,
>>>> bye" which is pretty much useless for anaylsis.
>
> Which may be all but impossible but for the handful of
> folks that know all the gory/intimate details of the
> original bit of code.
>
>> What does it potentially cause the caller to do?  Will it potentially
>> treat an error as a success and as a result register an object
>> illegally?
>>
>> Real analysis please.  The text you provided above is basically still
>> robotic and could be used to describe any error code return fix.
>
> Right, it's useful to attempt but may be infeasible in
> practice.
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe kernel-janitors" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
