From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4 net-next 1/1] net_sched: Introduce skbmod action
Date: Mon, 12 Sep 2016 15:26:32 -0700
Message-ID: <1473719192.18970.84.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1473713206-2450-1-git-send-email-jhs@emojatatu.com>
         <1473717691.18970.82.camel@edumazet-glaptop3.roam.corp.google.com>
         <77bca669-9113-3977-ad3c-478091422ff8@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        xiyou.wangcong@gmail.com, daniel@iogearbox.net,
        john.r.fastabend@intel.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:36606 "EHLO
        mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752078AbcILW0e (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 18:26:34 -0400
Received: by mail-pa0-f41.google.com with SMTP id id6so54749720pad.3
        for <netdev@vger.kernel.org>; Mon, 12 Sep 2016 15:26:34 -0700 (PDT)
In-Reply-To: <77bca669-9113-3977-ad3c-478091422ff8@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-09-12 at 18:14 -0400, Jamal Hadi Salim wrote:

> I noticed some very weird issues when I took that out.
> Running sufficiently large amount of traffic (ping -f is sufficient)
> I saw that when i did a dump it took anywhere between 6-15 seconds.
> With the read_lock in place response was immediate.
> I can go back and run things to verify - but it was very odd.

This was on uni processor ?

Looks like typical starvation caused by aggressive softirq.

Anyway, I suspect your kernel build has rcu_read_lock() and
rcu_read_unlock() as NOP ;)
