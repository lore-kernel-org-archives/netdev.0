From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [next-queue PATCH v3 2/4] net/sched: Fix accessing invalid
 dev_queue
Date: Tue, 03 Oct 2017 20:47:11 -0700
Message-ID: <1507088831.8061.41.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20171003234435.8979-1-vinicius.gomes@intel.com>
         <20171003234435.8979-3-vinicius.gomes@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
        Jesus Sanchez-Palencia <jesus.sanchez-palencia@intel.com>,
        jhs@mojatatu.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        andre.guedes@intel.com, ivan.briano@intel.com,
        boon.leong.ong@intel.com, richardcochran@gmail.com,
        henrik@austad.us, levipearson@gmail.com, rodney.cummings@ni.com
To: Vinicius Costa Gomes <vinicius.gomes@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:53964 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751148AbdJDDrN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 23:47:13 -0400
Received: by mail-pg0-f41.google.com with SMTP id j70so5830388pgc.10
        for <netdev@vger.kernel.org>; Tue, 03 Oct 2017 20:47:13 -0700 (PDT)
In-Reply-To: <20171003234435.8979-3-vinicius.gomes@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-10-03 at 16:44 -0700, Vinicius Costa Gomes wrote:
> From: Jesus Sanchez-Palencia <jesus.sanchez-palencia@intel.com>
> 
> In qdisc_alloc() the dev_queue pointer was used without any checks being
> performed. If qdisc_create() gets a null dev_queue pointer, it just
> passes it along to qdisc_alloc(), leading to a crash. That happens if a
> root qdisc implements select_queue() and returns a null dev_queue
> pointer for an "invalid handle", for example.
> 
> One way to reproduce that is:
> 
> 1) Setup mqprio
> $ tc qdisc replace dev enp3s0 parent root mqprio num_tc 3 \
>      	   map 2 2 1 0 2 2 2 2 2 2 2 2 2 2 2 2 queues 1@0 1@1 2@2 hw 0
> 
> 2) Replace the first inner qdisc
> $ tc qdisc replace dev enp3s0 parent 8001:1 pfifo_fast
> 
> This will lead to the following crash:

When was this bug added ?

If this is a consequence of your prior patch (1/4), then this must come
before it.

No need to add a stack trace for a not existing bug.
Instead, explain in the changelog that it is a prep work.

We try to not break the tree on purpose, so that future bisection will
not hit a point where the kernel crashes.
