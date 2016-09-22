From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 4/4] net/sched: act_mirred: Implement ingress
 actions
Date: Thu, 22 Sep 2016 07:54:13 -0700
Message-ID: <1474556053.23058.111.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1474550512-7552-1-git-send-email-shmulik.ladkani@gmail.com>
         <1474550512-7552-5-git-send-email-shmulik.ladkani@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        WANG Cong <xiyou.wangcong@gmail.com>,
        Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>
To: Shmulik Ladkani <shmulik.ladkani@ravellosystems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:34028 "EHLO
        mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756871AbcIVOyP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 10:54:15 -0400
Received: by mail-pa0-f66.google.com with SMTP id i5so618684pad.1
        for <netdev@vger.kernel.org>; Thu, 22 Sep 2016 07:54:15 -0700 (PDT)
In-Reply-To: <1474550512-7552-5-git-send-email-shmulik.ladkani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-09-22 at 16:21 +0300, Shmulik Ladkani wrote:
> From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
> 
> Up until now, 'action mirred' supported only egress actions (either
> TCA_EGRESS_REDIR or TCA_EGRESS_MIRROR).
> 
> This patch implements the corresponding ingress actions
> TCA_INGRESS_REDIR and TCA_INGRESS_MIRROR.
> 
> This allows attaching filters whose target is to hand matching skbs into
> the rx processing of a specified device.
> 
> Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> ---
>  Was wondering, whether netif_receive_skb or dev_forward_skb should be
>  used for the rx bouncing. Used netif_receive_skb as in ifb device.

Hmm... we probably need to apply the full rcu protection before this
patch.

https://patchwork.ozlabs.org/patch/667680/
