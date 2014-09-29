From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: remove rt6i_genid
Date: Mon, 29 Sep 2014 16:51:46 -0400 (EDT)
Message-ID: <20140929.165146.886742875592532179.davem@davemloft.net>
References: <7e1b4e2dbe855fa461a4e87e0482ac16b6982c2f.1411857958.git.hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	hideaki@yoshifuji.org, vyasevich@gmail.com,
	nicolas.dichtel@6wind.com, kafai@fb.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34017 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750968AbaI2Uvt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 16:51:49 -0400
In-Reply-To: <7e1b4e2dbe855fa461a4e87e0482ac16b6982c2f.1411857958.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Sun, 28 Sep 2014 00:46:06 +0200

> Eric Dumazet noticed that all no-nonexthop or no-gateway routes which
> are already marked DST_HOST (e.g. input routes routes) will always be
> invalidated during sk_dst_check. Thus per-socket dst caching absolutely
> had no effect and early demuxing had no effect.
> 
> Thus this patch removes rt6i_genid: fn_sernum already gets modified during
> add operations, so we only must ensure we mutate fn_sernum during ipv6
> address remove operations. This is a fairly cost extensive operations,
> but address removal should not happen that often. Also our mtu update
> functions do the same and we heard no complains so far. xfrm policy
> changes also cause a call into fib6_flush_trees. Also plug a hole in
> rt6_info (no cacheline changes).
> 
> I verified via tracing that this change has effect.
> 
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Ok, I'll apply this because it does correctly and simply fix the
problem now, thanks.

I'll also queue it up for -stable.

However, longer-term:

>  static inline void rt_genid_bump_ipv6(struct net *net)
>  {
> +	if (__fib6_flush_trees)
> +		__fib6_flush_trees(net);
>  }

I'd really like to see this go away.
