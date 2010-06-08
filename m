From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH net-2.6] pkt_sched: gen_estimator: add a new lock
Date: Tue, 8 Jun 2010 09:00:45 +0800
Message-ID: <AANLkTik7k__McJk8VCu0WP1RYEDHUfBJA4dyGYQTUmBV@mail.gmail.com>
References: <1275921171.2545.102.camel@edumazet-laptop> <AANLkTimgmYjA7Xp19gycRHDXmwP1w1twn92cfT08tCv2@mail.gmail.com>
	<1275924638.2545.121.camel@edumazet-laptop> <1275926151.2545.126.camel@edumazet-laptop>
	<1275929761.2545.159.camel@edumazet-laptop> <1275931108.2545.168.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Jarek Poplawski <jarkao2@gmail.com>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:44320 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751848Ab0FHBBF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jun 2010 21:01:05 -0400
Received: by pxi8 with SMTP id 8so1356429pxi.19
        for <netdev@vger.kernel.org>; Mon, 07 Jun 2010 18:01:05 -0700 (PDT)
In-Reply-To: <1275931108.2545.168.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 8, 2010 at 1:18 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
>
> [PATCH net-2.6] pkt_sched: gen_estimator: add a new lock
>
> gen_kill_estimator() / gen_new_estimator() is not always called with
> RTNL held.
>
> net/netfilter/xt_RATEEST.c is one user of these API that do not hold
> RTNL, so random corruptions can occur between "tc" and "iptables"
>
> Add a new fine grained lock instead of trying to use RTNL in xt_RATEEST
>

Why not use RTNL in xt_RATEEST? It seems xt_RATEEST misuse the APIs.

and I think gen_replace_estimator is expected to be an atomic operation.

And gen_estimator_active() is also assumed to be called with RTNL locked.

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
