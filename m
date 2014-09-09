From: Cong Wang <cwang@twopensource.com>
Subject: Re: [net-next PATCH v3 09/15] net: sched: make cls_u32 lockless
Date: Tue, 9 Sep 2014 11:02:46 -0700
Message-ID: <CAHA+R7NLq26v6K5j01WMjVd-NB9=3peUs1d-QPgfP0=MpU+Pug@mail.gmail.com>
References: <20140909055221.2071.99671.stgit@nitbit.x32>
	<20140909055815.2071.39668.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	netdev <netdev@vger.kernel.org>,
	Paul McKenney <paulmck@linux.vnet.ibm.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:62352 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750975AbaIISCs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2014 14:02:48 -0400
Received: by mail-la0-f45.google.com with SMTP id pn19so20104338lab.18
        for <netdev@vger.kernel.org>; Tue, 09 Sep 2014 11:02:46 -0700 (PDT)
In-Reply-To: <20140909055815.2071.39668.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 8, 2014 at 10:58 PM, John Fastabend
<john.fastabend@gmail.com> wrote:
>
> +void __u32_delete_key(struct rcu_head *rcu)
> +{
> +       struct tc_u_knode *key = container_of(rcu, struct tc_u_knode, rcu);
> +
> +       u32_destroy_key(key->tp, key);
> +}

This can become static?
