From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: sched: make default fifo qdiscs appear in the
 dump
Date: Wed, 01 Mar 2017 13:21:44 -0500 (EST)
Message-ID: <20170301.132144.1380602514921591101.davem@davemloft.net>
References: <alpine.LSU.2.20.1702252226530.24579@cbobk.fhfr.pm>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, eric.dumazet@gmail.com,
        jhs@mojatatu.com, phil@nwl.cc, xiyou.wangcong@gmail.com,
        daniel@iogearbox.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: jikos@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50020 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751542AbdCAScB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Mar 2017 13:32:01 -0500
In-Reply-To: <alpine.LSU.2.20.1702252226530.24579@cbobk.fhfr.pm>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Kosina <jikos@kernel.org>
Date: Sat, 25 Feb 2017 22:29:09 +0100 (CET)

> @@ -1066,6 +1066,7 @@ hfsc_change_class(struct Qdisc *sch, u32 classid, u32 parentid,
>  				      &pfifo_qdisc_ops, classid);
>  	if (cl->qdisc == NULL)
>  		cl->qdisc = &noop_qdisc;
> +	qdisc_hash_add(cl->qdisc, true);
>  	INIT_LIST_HEAD(&cl->children);
>  	cl->vt_tree = RB_ROOT;
>  	cl->cf_tree = RB_ROOT;
> @@ -1425,6 +1426,7 @@ hfsc_init_qdisc(struct Qdisc *sch, struct nlattr *opt)
>  					  sch->handle);
>  	if (q->root.qdisc == NULL)
>  		q->root.qdisc = &noop_qdisc;
> +	qdisc_hash_add(q->root.qdisc, true);
>  	INIT_LIST_HEAD(&q->root.children);
>  	q->root.vt_tree = RB_ROOT;
>  	q->root.cf_tree = RB_ROOT;

I'm not so sure it is legal is potentially pass &noop_qdisc into qdisc_hash_add().
