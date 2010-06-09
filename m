From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH net-2.6 v2] pkt_sched: gen_estimator: add a new lock
Date: Wed, 9 Jun 2010 11:33:29 +0000
Message-ID: <20100609113329.GC7308@ff.dom.local>
References: <1275921171.2545.102.camel@edumazet-laptop> <AANLkTimgmYjA7Xp19gycRHDXmwP1w1twn92cfT08tCv2@mail.gmail.com> <1275924638.2545.121.camel@edumazet-laptop> <1275926151.2545.126.camel@edumazet-laptop> <1275929761.2545.159.camel@edumazet-laptop> <1275931108.2545.168.camel@edumazet-laptop> <1276076350.2442.90.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Changli Gao <xiaosuo@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:33349 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757296Ab0FILdd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jun 2010 07:33:33 -0400
Received: by fxm8 with SMTP id 8so3504104fxm.19
        for <netdev@vger.kernel.org>; Wed, 09 Jun 2010 04:33:31 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1276076350.2442.90.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 09, 2010 at 11:39:10AM +0200, Eric Dumazet wrote:
...
> Here is v2 of patch, adding protection in gen_estimator_active() as
> well.
> 
> [PATCH net-2.6 v2] pkt_sched: gen_estimator: add a new lock
> 
> gen_kill_estimator() / gen_new_estimator() is not always called with
> RTNL held.
> 
> net/netfilter/xt_RATEEST.c is one user of these API that do not hold
> RTNL, so random corruptions can occur between "tc" and "iptables".
> 
> Add a new fine grained lock instead of trying to use RTNL in netfilter.

Btw, maybe it's a different case, but RTNL happens in netfilter already
(nf_conntrack_helper.c, nf_conntrack_proto.c).

It would be nice to mention Changli's argument that
gen_replace_estimator isn't atomic operation after this change.

> @@ -312,8 +315,14 @@ EXPORT_SYMBOL(gen_replace_estimator);
>  bool gen_estimator_active(const struct gnet_stats_basic_packed *bstats,
>  			  const struct gnet_stats_rate_est *rate_est)
>  {
> +	bool res;
> +
>  	ASSERT_RTNL();

This line should go away as well.

I'm OK with this patch unless there is an alternative xt_RATEEST RTNL
fix available.

Jarek P.
