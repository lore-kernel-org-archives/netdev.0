From: Cong Wang <cwang@twopensource.com>
Subject: Re: [Patch net-next v2 2/4] net_sched: update hierarchical backlog too
Date: Mon, 2 Nov 2015 13:50:40 -0800
Message-ID: <CAHA+R7MogROyXLDhT7FrVLiLRhJueB0DmKGVDr49xDxcT2Q2KA@mail.gmail.com>
References: <1446229351-13412-1-git-send-email-xiyou.wangcong@gmail.com>
	<1446229351-13412-3-git-send-email-xiyou.wangcong@gmail.com>
	<1446233450.6254.29.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAHA+R7NkU3Bme5MbgFraOo=7SRYUF+F-6owyzFxfVidjc2AxMw@mail.gmail.com>
	<1446499257.23275.33.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f176.google.com ([209.85.160.176]:36552 "EHLO
	mail-yk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751711AbbKBVul (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2015 16:50:41 -0500
Received: by ykba4 with SMTP id a4so153583676ykb.3
        for <netdev@vger.kernel.org>; Mon, 02 Nov 2015 13:50:40 -0800 (PST)
In-Reply-To: <1446499257.23275.33.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 2, 2015 at 1:20 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> Well, before your changes, the qdisc_tree_decrease_qlen(sch, 0) would
> have been useless, since qdisc_tree_decrease_qlen() does nothing in this
> case [1]
>
> But after your changes, we need to change the backlog, even if the qlen
> does not change.
>
> Maybe I missed something, but your patch is not really obvious ;)
>

Oh, very good point... You actually mean in some cases we enqueue
one packet and then drop one packet which ends up with dropping 0
packet but the backlog size goes down by (drop_len - enqueue_len). :)

Hmm, I need to double check for this case for sure, but for sfq case,
I just did:

-       qdisc_tree_decrease_qlen(sch, 1);
+       qdisc_tree_reduce_backlog(sch, 1, dropped);

which isn't the case where n==0, like you mentioned.

I am auditing that case for all the qdisc's anyway.

Thanks.
