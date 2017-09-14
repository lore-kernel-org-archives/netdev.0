From: liujian <liujian56@huawei.com>
Subject: Re: [PATCH net] tcp: update skb->skb_mstamp more carefully
Date: Thu, 14 Sep 2017 16:17:20 +0800
Message-ID: <6c8fd260-f2a1-4377-2dd8-5975249ab597@huawei.com>
References: <1505111262-12620-1-git-send-email-liujian56@huawei.com>
 <1505141357.15310.115.camel@edumazet-glaptop3.roam.corp.google.com>
 <1505142785.15310.117.camel@edumazet-glaptop3.roam.corp.google.com>
 <1505143348.15310.118.camel@edumazet-glaptop3.roam.corp.google.com>
 <e7e09201-40c2-933a-1e8e-a31eddcc75ab@huawei.com>
 <1505228700.15310.138.camel@edumazet-glaptop3.roam.corp.google.com>
 <1505230686.15310.141.camel@edumazet-glaptop3.roam.corp.google.com>
 <b72fefba-e701-2ec8-0e7b-3bba6ed25205@huawei.com>
 <3c750ac3-8739-89ed-ce41-d4cde755171e@huawei.com>
 <1505313647.15310.165.camel@edumazet-glaptop3.roam.corp.google.com>
 <1505359839.15310.209.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <edumazet@google.com>, <ycheng@google.com>, <hkchu@google.com>,
        <netdev@vger.kernel.org>, <weiyongjun1@huawei.com>,
        wangkefeng 00227729 <wangkefeng.wang@huawei.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga05-in.huawei.com ([45.249.212.191]:6054 "EHLO
        szxga05-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751181AbdINIXU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 14 Sep 2017 04:23:20 -0400
In-Reply-To: <1505359839.15310.209.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017/9/14 11:30, Eric Dumazet worte:
> From: Eric Dumazet <edumazet@googl.com>
> 
> liujian reported a problem in TCP_USER_TIMEOUT processing with a patch
> in tcp_probe_timer() :
>       https://www.spinics.net/lists/netdev/msg454496.html
> 
> After investigations, the root cause of the problem is that we update
> skb->skb_mstamp of skbs in write queue, even if the attempt to send a
> clone or copy of it failed. One reason being a routing problem.
> 
> This patch prevents this, solving liujian issue.
> 
> It also removes a potential RTT miscalculation, since
> __tcp_retransmit_skb() is not OR-ing TCP_SKB_CB(skb)->sacked with
> TCPCB_EVER_RETRANS if a failure happens, but skb->skb_mstamp has
> been changed.
> 
> A future ACK would then lead to a very small RTT sample and min_rtt
> would then be lowered to this too small value.
> 
>

I test  on 4.13, it can work.
thank you!
