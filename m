From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH 3/4] net: avoid false perf interpretations in
 frag code
Date: Thu, 25 Apr 2013 12:57:08 +0200
Message-ID: <1366887428.26911.542.camel@localhost>
References: <20130424154624.16883.40974.stgit@dragon>
	 <20130424154836.16883.79599.stgit@dragon>
	 <1366847307.8964.89.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56533 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755196Ab3DYMmp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Apr 2013 08:42:45 -0400
In-Reply-To: <1366847307.8964.89.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-04-24 at 16:48 -0700, Eric Dumazet wrote:
> On Wed, 2013-04-24 at 17:48 +0200, Jesper Dangaard Brouer wrote:
> > The compiler make us misinterpret performance issues in the frag code,
> > because its auto inlining functions.  Lets instead do explicit
> > inlining to make this situation obvious to the programmer.
> > 
> > The function inet_frag_find() get the perf blame, because auto
> > inlining of the functions inet_frag_create(), inet_frag_alloc() and
> > inet_frag_intern().
> > 
> > My solution is to explicit inline inet_frag_alloc() and
> > inet_frag_intern(), but explicitly "noinline" inet_frag_create(),
> > in-order to make it explicit to the performance engineer, that
> > creation phase is a bottleneck. Then, when reading the code the
> > programmer should notice the inline, and see the bottleneck is really
> > located in inet_frag_intern().
> > 
> > Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> > ---
> 
> There is no way we add inline/noinline attributes to help developers to
> use performance tools.

I take that as a NACK

Would we add the "inlines" only to the code, to make it clear what is
happening in the code?
