From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] ipv6: rename __ipv6_addr_jhash()
Date: Fri, 01 Aug 2014 10:47:27 +0200
Message-ID: <1406882847.1781790.147998398.54D3639D@webmail.messagingengine.com>
References: <1406756298.3178.52.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140731.215646.951740411089334213.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:41619 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751492AbaHAIr2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2014 04:47:28 -0400
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by gateway1.nyi.internal (Postfix) with ESMTP id 129D62122B
	for <netdev@vger.kernel.org>; Fri,  1 Aug 2014 04:47:27 -0400 (EDT)
In-Reply-To: <20140731.215646.951740411089334213.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Fri, Aug 1, 2014, at 06:56, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 30 Jul 2014 23:38:18 +0200
> 
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > Remove '__' prefix, it has no purpose.
> > 
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> 
> Actually, I think it does.
> 
> If you look at where this came from, it's commit:
> 
> commit b50026b5ac8fe2932e6af0c54b21da0913c4c1c7
> Author: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date:   Sat Oct 19 21:48:52 2013 +0200
> 
>     ipv6: split inet6_ehashfn to hash functions per compilation unit
> 
> and in that change Hannes uses the convention that __foo() functions
> take an initval argument for the hash computation where as foo()
> functions do not.
> 
> I'm not applying this, sorry :)

The idea was that all the hashing functions (like socket hashing etc.)
provide the secret to ipv6_addr_jhash and thus this function should not
be called directly but by helper functions. I normally use '__' prefixed
function which need a bit more care to handle them correctly (e.g.
unlocked versions, argument hiding etc.) and I think this was also the
reason I did so at that time.

That said, nowadays most hashing functions need (should have) a secret
in the network stack and programmers should already know how to deal
with that. I don't have a strong opinion on that but would be fine if
you apply Eric's patch.

Thanks,
Hannes
