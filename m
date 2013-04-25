From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH 4/4] net: frag LRU list per CPU
Date: Wed, 24 Apr 2013 19:05:46 -0700
Message-ID: <1366855546.8964.125.camel@edumazet-glaptop>
References: <20130424154624.16883.40974.stgit@dragon>
	 <20130424154848.16883.65833.stgit@dragon>
	 <1366849557.8964.110.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:46281 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932227Ab3DYCFs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Apr 2013 22:05:48 -0400
Received: by mail-pa0-f43.google.com with SMTP id hz1so1547972pad.2
        for <netdev@vger.kernel.org>; Wed, 24 Apr 2013 19:05:48 -0700 (PDT)
In-Reply-To: <1366849557.8964.110.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-04-24 at 17:25 -0700, Eric Dumazet wrote:

> We know that a slow sender has no chance to complete a packet if the
> attacker can create new fragments fast enough : frag_evictor() will keep
> the attacker fragments in memory and throw away good fragments.
> 

By the way, the frag_evictor() idea of cleaning 20% or 30% of the frags
simply doesn't scale to thousands of fragments.

It adds huge latencies in softirq context.

If we really want to evict old fragments before expiration timer, then
we can introduce a garbage collector in a work queue, and remove the
need of a timer per fragment.
