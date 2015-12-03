From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 2/5] rhashtable: add function to replace an
 element
Date: Thu, 03 Dec 2015 14:45:58 -0500 (EST)
Message-ID: <20151203.144558.1956397517705186998.davem@davemloft.net>
References: <1449011472-1459652-1-git-send-email-tom@herbertland.com>
	<1449011472-1459652-3-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44536 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753022AbbLCTqA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 14:46:00 -0500
In-Reply-To: <1449011472-1459652-3-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Tue, 1 Dec 2015 15:11:09 -0800

> +	lock = rht_bucket_lock(tbl, hash);
> +
> +	spin_lock_bh(lock);
> +
> +	pprev = &tbl->buckets[hash];
> +	rht_for_each(he, tbl, hash) {
> +		if (he != obj_old) {
> +			pprev = &he->next;
> +			continue;
> +		}
> +
> +		rcu_assign_pointer(obj_new->next, obj_old->next);
> +		rcu_assign_pointer(*pprev, obj_new);
> +		err = 0;
> +		break;

Are you sure this works fine in the presence of both parallel readers and
table expansion passes?
