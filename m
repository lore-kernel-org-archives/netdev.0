From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH 05/15] net: sched: a dflt qdisc may be used
 with per cpu stats
Date: Wed, 24 Aug 2016 10:26:50 -0700
Message-ID: <1472059610.14381.103.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160823202135.14368.62466.stgit@john-Precision-Tower-5810>
         <20160823202445.14368.4352.stgit@john-Precision-Tower-5810>
         <1472056898.14381.95.camel@edumazet-glaptop3.roam.corp.google.com>
         <57BDD5AE.8030208@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, davem@davemloft.net, brouer@redhat.com,
        xiyou.wangcong@gmail.com, alexei.starovoitov@gmail.com,
        john.r.fastabend@intel.com, netdev@vger.kernel.org
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36484 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754297AbcHXR06 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 13:26:58 -0400
Received: by mail-pf0-f196.google.com with SMTP id y134so1568117pfg.3
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2016 10:26:51 -0700 (PDT)
In-Reply-To: <57BDD5AE.8030208@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-08-24 at 10:13 -0700, John Fastabend wrote:

> > 
> 
> I could fully allocate it in qdisc_alloc() but we don't know if the
> qdisc needs per cpu data structures until after the init call

Should not we have a flag to advertise the need of per spu stats on
qdisc ?

This is not clear why ->init() can know this, and not its caller.

> . So it
> would sit unused in those cases if done from qdisc_alloc(). It seems
> best to me at least to just avoid the allocation in qdisc_alloc() and
> do it after init like I did here.
> 
> Perhaps it would be nice to pull these into a function call
> post_init_qdisc_alloc() that does all this allocation?
> 
> .John
> 
