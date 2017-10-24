From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] tcp/dccp: fix other lockdep splats accessing
 ireq_opt
Date: Tue, 24 Oct 2017 18:56:16 +0900 (KST)
Message-ID: <20171024.185616.1718355795918406578.davem@davemloft.net>
References: <20171023095634.lednbqrxtbuooqcx@inn>
        <1508770960.30291.83.camel@edumazet-glaptop3.roam.corp.google.com>
        <1508800508.30291.104.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fengguang.wu@intel.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58450 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751876AbdJXJ4U (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 05:56:20 -0400
In-Reply-To: <1508800508.30291.104.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 23 Oct 2017 16:15:08 -0700

> +static inline struct ip_options_rcu *ireq_opt_deref(const struct inet_request_sock *ireq)
> +{
> +	return rcu_dereference_check(ireq->ireq_opt,
> +				     refcount_read(&ireq.req->rsk_refcnt) > 0);
                                                    ^^^^^^^^^

Eric, _please_ build test your changes properly.
