From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH net-next-2.6] tcp: connect() race with timewait reuse
Date: Thu, 3 Dec 2009 01:15:53 +0300
Message-ID: <20091202221552.GA17579@ioremap.net>
References: <99d458640911301802i4bde20f4wa314668d543e3170@mail.gmail.com> <4B152F97.1090409@gmail.com> <20091202.005937.177088443.davem@davemloft.net> <4B163226.50801@gmail.com> <4B164293.7070804@gmail.com> <4B16830B.4010801@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, kdakhane@gmail.com,
	netdev@vger.kernel.org, netfilter@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kandzendo.ru ([195.178.208.66]:56184 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755701AbZLBWPr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Dec 2009 17:15:47 -0500
Content-Disposition: inline
In-Reply-To: <4B16830B.4010801@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

Looks very good, thanks Eric, I have one question.

On Wed, Dec 02, 2009 at 04:08:59PM +0100, Eric Dumazet (eric.dumazet@gmail.com) wrote:
> +
> +/*
> + * unhash a timewait socket from established hash
> + * lock must be hold by caller
> + */
> +void inet_twsk_unhash(struct inet_timewait_sock *tw)
> +{
> +	if (hlist_nulls_unhashed(&tw->tw_node))
> +		return;
> +
> +	hlist_nulls_del_rcu(&tw->tw_node);
> +	sk_nulls_node_init(&tw->tw_node);
> +	inet_twsk_put(tw);

Is it safe to call in locked context? inet_twsk_put() schedules
preemption, also I did not check what tw destructor does.

-- 
	Evgeniy Polyakov
