From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 net 1/1] net sched actions: fix GETing actions
Date: Mon, 19 Sep 2016 01:30:27 -0400 (EDT)
Message-ID: <20160919.013027.1888284719644827986.davem@davemloft.net>
References: <1474057624-17914-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53224 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755785AbcISFaa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 01:30:30 -0400
In-Reply-To: <1474057624-17914-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>
Date: Fri, 16 Sep 2016 16:27:04 -0400

> Fixes:
> commit 22dc13c837c3 ("net_sched: convert tcf_exts from list to pointer array"),
> commit 824a7e8863b3 ("net_sched: remove an unnecessary list_del()")
> commit f07fed82ad79 ("net_sched: remove the leftover cleanup_a()")

Please use multiple "Fixes: " lines to reference multiple commits, like so:


Fixes: 22dc13c837c3 ("net_sched: convert tcf_exts from list to pointer array"),
Fixes: 824a7e8863b3 ("net_sched: remove an unnecessary list_del()")
Fixes: f07fed82ad79 ("net_sched: remove the leftover cleanup_a()")

> +static void cleanup_a(struct list_head *actions, int ovr)
> +{
> +	struct tc_action *a;
> +
> +	list_for_each_entry(a, actions, list) {
> +		if (ovr)
> +			a->tcfa_refcnt--;
> +	}
> +}

Please move the invariant test outside of the loop, like so:

	if (!ovr)
		return;
	list_for_each_entry(a, actions, list)
		a->tcfa_refcnt--;

Thanks.
