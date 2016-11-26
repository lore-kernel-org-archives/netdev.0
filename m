From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next] net_sched: move the empty tp check from
 ->destroy() to ->delete()
Date: Fri, 25 Nov 2016 22:46:41 -0800
Message-ID: <CAM_iQpVxevmk3rgsnALC0JCqx7pOF2OBc=kpg9QDK8Cwb6P9Zw@mail.gmail.com>
References: <1479952708-26763-1-git-send-email-xiyou.wangcong@gmail.com>
 <5836A4D4.2010500@mellanox.com> <5836BD82.6080407@iogearbox.net>
 <5836C87E.8050506@mellanox.com> <58370558.9070004@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Roi Dayan <roid@mellanox.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>,
        John Fastabend <john.fastabend@gmail.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:33175 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750762AbcKZGrC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 26 Nov 2016 01:47:02 -0500
Received: by mail-io0-f196.google.com with SMTP id j92so13136177ioi.0
        for <netdev@vger.kernel.org>; Fri, 25 Nov 2016 22:47:02 -0800 (PST)
In-Reply-To: <58370558.9070004@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 24, 2016 at 7:20 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
>
> Ok, strange, qdisc_destroy() calls into ops->destroy(), where ingress
> drops its entire chain via tcf_destroy_chain(), so that will be NULL
> eventually. The tps are freed by call_rcu() as well as qdisc itself
> later on via qdisc_rcu_free(), where it frees per-cpu bstats as well.
> Outstanding readers should either bail out due to if (!cl) or can still
> process the chain until read section ends, but during that time, cl->q
> resp. bstats should be good. Do you happen to know what's at address
> ffff880a68b04028? I was wondering wrt call_rcu() vs call_rcu_bh(), but
> at least on ingress (netif_receive_skb_internal()) we hold rcu_read_lock()
> here. The KASAN report is reliably happening at this location, right?

I am confused as well, I don't see how it could be related to my patch yet.
I will take a deep look in the weekend.

Thanks!
