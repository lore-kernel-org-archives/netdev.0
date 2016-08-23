From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH 03/15] net: sched: remove remaining uses for
 qdisc_qlen in xmit path
Date: Tue, 23 Aug 2016 14:10:45 -0700
Message-ID: <1471986645.14381.57.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160823202135.14368.62466.stgit@john-Precision-Tower-5810>
         <20160823202347.14368.78284.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, davem@davemloft.net, brouer@redhat.com,
        xiyou.wangcong@gmail.com, alexei.starovoitov@gmail.com,
        john.r.fastabend@intel.com, netdev@vger.kernel.org
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:35099 "EHLO
        mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757371AbcHWVXS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 17:23:18 -0400
Received: by mail-pa0-f67.google.com with SMTP id cf3so10466297pad.2
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2016 14:23:13 -0700 (PDT)
In-Reply-To: <20160823202347.14368.78284.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-08-23 at 13:23 -0700, John Fastabend wrote:
> sch_direct_xmit() uses qdisc_qlen as a return value but all call sites
> of the routine only check if it is zero or not. Simplify the logic so
> that we don't need to return an actual queue length value.
> 
> This introduces a case now where sch_direct_xmit would have returned
> a qlen of zero but now it returns true. However in this case all
> call sites of sch_direct_xmit will implement a dequeue() and get
> a null skb and abort. This trades tracking qlen in the hotpath for
> an extra dequeue operation. Overall this seems to be good for
> performance.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
