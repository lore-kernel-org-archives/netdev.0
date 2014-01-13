From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next 6/7] net_sched: cls: move allocation in ->init
 to generic layer
Date: Mon, 13 Jan 2014 11:49:23 -0800 (PST)
Message-ID: <20140113.114923.2164522715863402981.davem@davemloft.net>
References: <1389312845-10304-1-git-send-email-xiyou.wangcong@gmail.com>
	<1389312845-10304-7-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tgraf@suug.ch, jhs@mojatatu.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38182 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750899AbaAMTtY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 14:49:24 -0500
In-Reply-To: <1389312845-10304-7-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Thu,  9 Jan 2014 16:14:04 -0800

> +	if (!head->init) {
>  		head->handle = handle;
> -
> -		tcf_tree_lock(tp);
> -		tp->root = head;
> -		tcf_tree_unlock(tp);
> +		head->init = true;
 ...
>  		head->mask = mask;
> -
> -		tcf_tree_lock(tp);
> -		tp->root = head;
> -		tcf_tree_unlock(tp);
> +		head->init = true;

Like Jamal, I don't think these transformations are valid.

You can't make the root visible in the hierarchy until the
->handle and ->mask (respectively) members are initialized
in these two classifiers.

What I'm going to do for now is apply patches 1-5 and 7.

Thanks.
