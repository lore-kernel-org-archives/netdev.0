From: Max Krasnyansky <maxk@qualcomm.com>
Subject: Re: [PATCH] Crash in tun
Date: Thu, 19 Jul 2012 10:57:12 -0700
Message-ID: <50084A78.6060602@qualcomm.com>
References: <1342678175.2626.3849.camel@edumazet-glaptop> <alpine.DEB.2.00.1207191746170.7550@artax.karlin.mff.cuni.cz> <50084761.1030602@qualcomm.com> <20120719.104721.1649022907880598997.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <mikulas@artax.karlin.mff.cuni.cz>, <eric.dumazet@gmail.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine02.qualcomm.com ([199.106.114.251]:56294 "EHLO
	wolverine02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752845Ab2GSR5T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2012 13:57:19 -0400
In-Reply-To: <20120719.104721.1649022907880598997.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/19/2012 10:47 AM, David Miller wrote:
> From: Max Krasnyansky <maxk@qualcomm.com>
> Date: Thu, 19 Jul 2012 10:44:01 -0700
> 
>> btw I don't remember now who added the socket business to tun_struct and why.
> 
> Is GIT really so broken on your computer that you can't find the
> answer to this question in like 5 seconds as I just did?

No. I'm just too lazy these days. Too much surfing I guess :).

> commit 33dccbb050bbe35b88ca8cf1228dcf3e4d4b3554
> Author: Herbert Xu <herbert@gondor.apana.org.au>
> Date:   Thu Feb 5 21:25:32 2009 -0800
> 
>     tun: Limit amount of queued packets per device
> <snip>     
>     This patch attempts to apply the same bandaid to the tuntap device.
>     It creates a pseudo-socket object which is used to account our
>     packets just as a normal socket does for UDP.  Of course things
>     are a little complex because we're actually reinjecting traffic
>     back into the stack rather than out of the stack.

Thanks for the info. Overall it definitely makes sense. Still feels a bit of an overkill.
i.e. That we need to allocated a socket just for accounting but I guess all the involved
skb primitives are heavily based on that. If there are other use cases like this maybe
it makes sense to factor accounting stuff out of the socket struct?

Max
