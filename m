From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH 3/4] net: avoid false perf interpretations in
 frag code
Date: Wed, 24 Apr 2013 16:48:27 -0700
Message-ID: <1366847307.8964.89.camel@edumazet-glaptop>
References: <20130424154624.16883.40974.stgit@dragon>
	 <20130424154836.16883.79599.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:40545 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757971Ab3DXXsa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Apr 2013 19:48:30 -0400
Received: by mail-pb0-f51.google.com with SMTP id rr4so597732pbb.38
        for <netdev@vger.kernel.org>; Wed, 24 Apr 2013 16:48:29 -0700 (PDT)
In-Reply-To: <20130424154836.16883.79599.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-04-24 at 17:48 +0200, Jesper Dangaard Brouer wrote:
> The compiler make us misinterpret performance issues in the frag code,
> because its auto inlining functions.  Lets instead do explicit
> inlining to make this situation obvious to the programmer.
> 
> The function inet_frag_find() get the perf blame, because auto
> inlining of the functions inet_frag_create(), inet_frag_alloc() and
> inet_frag_intern().
> 
> My solution is to explicit inline inet_frag_alloc() and
> inet_frag_intern(), but explicitly "noinline" inet_frag_create(),
> in-order to make it explicit to the performance engineer, that
> creation phase is a bottleneck. Then, when reading the code the
> programmer should notice the inline, and see the bottleneck is really
> located in inet_frag_intern().
> 
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> ---

There is no way we add inline/noinline attributes to help developers to
use performance tools.

noinline can make sense when we want to avoid consuming too much stack
space, and in this case we use the explicit noinline_for_stack.

Another case would be when we know a particular function is called on
very rare occasions, and we want to avoid compiler being smart and
inline the function in the caller.
