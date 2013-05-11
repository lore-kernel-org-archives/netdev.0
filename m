From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: do not clear pinet6 field
Date: Sat, 11 May 2013 16:27:21 -0700 (PDT)
Message-ID: <20130511.162721.884139879091826308.davem@davemloft.net>
References: <1368131296.13473.101.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60277 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751900Ab3EKX1V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 May 2013 19:27:21 -0400
In-Reply-To: <1368131296.13473.101.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 09 May 2013 13:28:16 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> We have seen multiple NULL dereferences in __inet6_lookup_established()
> 
> After analysis, I found that inet6_sk() could be NULL while the
> check for sk_family == AF_INET6 was true.
> 
> Bug was added in linux-2.6.29 when RCU lookups were introduced in UDP
> and TCP stacks.
> 
> Once an IPv6 socket, using SLAB_DESTROY_BY_RCU is inserted in a hash
> table, we no longer can clear pinet6 field.
> 
> This patch extends logic used in commit fcbdf09d9652c891
> ("net: fix nulls list corruptions in sk_prot_alloc")
> 
> TCP/UDP/UDPLite IPv6 protocols provide their own .clear_sk() method
> to make sure we do not clear pinet6 field.
> 
> At socket clone phase, we do not really care, as cloning the parent (non
> NULL) pinet6 is not adding a fatal race.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks!
