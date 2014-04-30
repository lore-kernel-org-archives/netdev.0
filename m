From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH 01/15] net: qdisc: use rcu prefix and silence sparse
 warnings
Date: Wed, 30 Apr 2014 10:00:28 -0700
Message-ID: <1398877228.29914.177.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140430163250.9021.21199.stgit@nitbit.x32>
	 <20140430163504.9021.12828.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, jhs@mojatatu.com, netdev@vger.kernel.org,
	davem@davemloft.net
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:40677 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752425AbaD3RAj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2014 13:00:39 -0400
Received: by mail-pd0-f176.google.com with SMTP id y10so1938858pdj.35
        for <netdev@vger.kernel.org>; Wed, 30 Apr 2014 10:00:35 -0700 (PDT)
In-Reply-To: <20140430163504.9021.12828.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-04-30 at 09:35 -0700, John Fastabend wrote:

>  static inline struct Qdisc *qdisc_root(const struct Qdisc *qdisc)
>  {
> -	return qdisc->dev_queue->qdisc;
> +	struct Qdisc *q = rcu_dereference(qdisc->dev_queue->qdisc);
> +
> +	return q;
>  }
>  

Hmm... I am pretty sure this can be called without rcu_read_lock()

rcu_dereference_rtnl() would be more appropriate here I think.
