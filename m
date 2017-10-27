From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net 01/16] net_sched: introduce a workqueue for RCU
 callbacks of tc filter
Date: Fri, 27 Oct 2017 08:43:34 -0700
Message-ID: <CAM_iQpUxG3Bqkg2HJMjAKGe4Cg8TXCDsdSaHYoF_e7oNwWOmwg@mail.gmail.com>
References: <20171027012443.3306-1-xiyou.wangcong@gmail.com>
 <20171027012443.3306-2-xiyou.wangcong@gmail.com> <1509077103.11887.23.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpUB_y5=Pa9z5Vq+Ves9GhT5COXvRbDtRZo2xqxjo__vmw@mail.gmail.com>
 <1509079166.11887.33.camel@edumazet-glaptop3.roam.corp.google.com> <20171027115550.GG3659@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Chris Mi <chrism@mellanox.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Jiri Pirko <jiri@resnulli.us>,
        John Fastabend <john.fastabend@gmail.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:48813 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751164AbdJ0Pnz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 11:43:55 -0400
Received: by mail-pf0-f193.google.com with SMTP id b79so5224912pfk.5
        for <netdev@vger.kernel.org>; Fri, 27 Oct 2017 08:43:55 -0700 (PDT)
In-Reply-To: <20171027115550.GG3659@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 27, 2017 at 4:55 AM, Paul E. McKenney
<paulmck@linux.vnet.ibm.com> wrote:
>
> Would this be a good time for me to repeat my suggestion that timers
> be used to aggregate the work done in the workqueue handlers, thus
> decreasing the number of rcu_barrier() calls done under RTNL?
>

Yes, but not in this patchset. The current code is already so, therefore
needs a different patchset.

Quite contrarily, my patchset actually improves it _a little bit_ by moving
the second rcu_barrier() in current code base to a workqueue... The
contention is same, just that we no longer block tcf_block_put() path
with my patchset.
