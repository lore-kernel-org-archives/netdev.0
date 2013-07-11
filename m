From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v3] ipv6: fix route selection if kernel is not
 compiled with CONFIG_IPV6_ROUTER_PREF
Date: Thu, 11 Jul 2013 11:51:42 -0700 (PDT)
Message-ID: <20130711.115142.733130366565562474.davem@davemloft.net>
References: <20130711104342.GD5207@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, petrus.lt@gmail.com,
	yoshfuji@linux-ipv6.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58454 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932110Ab3GKSvn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 14:51:43 -0400
In-Reply-To: <20130711104342.GD5207@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Thu, 11 Jul 2013 12:43:42 +0200

> This is a follow-up patch to 3630d40067a21d4dfbadc6002bb469ce26ac5d52
> ("ipv6: rt6_check_neigh should successfully verify neigh if no NUD
> information are available").
> 
> Since the removal of rt->n in rt6_info we can end up with a dst ==
> NULL in rt6_check_neigh. In case the kernel is not compiled with
> CONFIG_IPV6_ROUTER_PREF we should also select a route with unkown
> NUD state but we must not avoid doing round robin selection on routes
> with the same target. So introduce and pass down a boolean ``do_rr'' to
> indicate when we should update rt->rr_ptr. As soon as no route is valid
> we do backtracking and do a lookup on a higher level in the fib trie.
> 
> v2:
> a) Improved rt6_check_neigh logic (no need to create neighbour there)
>    and documented return values.
> 
> v3:
> a) Introduce enum rt6_nud_state to get rid of the magic numbers
>    (thanks to David Miller).
> b) Update and shorten commit message a bit to actualy reflect
>    the source.
> 
> Reported-by: Pierre Emeriaud <petrus.lt@gmail.com>
> Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Looks good, applied, thanks.
