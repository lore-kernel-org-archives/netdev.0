From: Patrick McHardy <kaber@trash.net>
Subject: Re: Possible regression in HTB
Date: Wed, 08 Oct 2008 02:31:26 +0200
Message-ID: <48EBFF5E.1090902@trash.net>
References: <48EB5A92.6010704@trash.net> <20081007220022.GA2664@ami.dom.local> <20081008002153.GL12021@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Martin Devera <devik@cdi.cz>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64303 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753163AbYJHAc5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2008 20:32:57 -0400
In-Reply-To: <20081008002153.GL12021@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simon Horman wrote:
> On Wed, Oct 08, 2008 at 12:00:22AM +0200, Jarek Poplawski wrote:
>   
>> Anyway, IMHO this regression is really doubtful: since the digits are
>> wrong in both cases I can only agree the old method gives better wrong
>> results...
>>     
>
> I first started looking into this problem because I noticed that
> borrowing wasn't working in the correct proportions. That is
> the problem that Patrick pointed out and you re-did the maths for above.
>
> I noticed this on 2.6.26-rc7. So I did some testing on older kernels and
> noticed that although 2.6.26-rc7 was imperfect, it did seem that progress
> was being made in the right direction.  Though unfortunately there is noise
> in the results, so the trend may not be real. It was also unfortunate that
> I was not able to get any older kernels to boot on the hw that I was using
> for testing (an HP dl360-g5 - any kernel-config tips welcome).
>
> [...]

> noticed that things were not good, as I
> reported in my opening post for this thread. Curiously, the trivial revert
> patch that I posted, when applied on top of yesterdays's net-next-2.6
> ("tcp: Respect SO_RCVLOWAT in tcp_poll()"), gives the closest to ideal
> result that I have seen in any test.
>
> 10194: 666780666bits/s 666Mbits/s
> 10197: 141154197bits/s 141Mbits/s
> 10196: 141023090bits/s 141Mbits/s
> -----------------------------------
> total: 948957954bits/s 948Mbits/s
>
>
> That does indeed seem promising. Though I do realise that my methods
> have essentially been stabs in the dark and the problem needs to
> be understood.
>   

I'm pretty sure that the differences are caused by HTB not being
in control of the queue since the device is the real bottleneck
in this configuration. Its quite possible that there simply might
a subtle timing change that causes feedback through HTBs borrowing
and ceiling.

So what would really be useful to understand this is to make HTB
control the queue and see if it behaves as expected.

