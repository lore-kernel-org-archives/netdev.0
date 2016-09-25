From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net-next 4/4] net/sched: act_mirred: Implement ingress
 actions
Date: Sun, 25 Sep 2016 20:31:36 +0200
Message-ID: <20160925183136.GA3307@breakpoint.cc>
References: <1474550512-7552-1-git-send-email-shmulik.ladkani@gmail.com>
 <1474550512-7552-5-git-send-email-shmulik.ladkani@gmail.com>
 <4387324a-de66-aa1b-86f0-1a9a2f8294f5@mojatatu.com>
 <20160923081106.73fb48df@halley>
 <0037729a-a3fc-c1c9-a620-905c73e0b9d4@mojatatu.com>
 <20160923184030.75124289@halley>
 <6d2bd45a-a8a0-846d-5934-5e246522cab8@mojatatu.com>
 <20160925203309.633cf3d5@halley>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
        "David S. Miller" <davem@davemloft.net>,
        WANG Cong <xiyou.wangcong@gmail.com>,
        Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
        Florian Westphal <fw@strlen.de>,
        Daniel Borkmann <daniel@iogearbox.net>
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:55442 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755677AbcIYSbn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 25 Sep 2016 14:31:43 -0400
Content-Disposition: inline
In-Reply-To: <20160925203309.633cf3d5@halley>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Shmulik Ladkani <shmulik.ladkani@gmail.com> wrote:
> We can later address any loop-detection improvements in mirred.
> WDYT?

You can address this after fixing infamous spinlock recursion hard
lockup (which has existed forever):

tc qdisc add dev eth0 root handle 1: prio
tc filter add dev eth0 parent 1: protocol ip u32 match u32 0 0 flowid
1:2 action mirred egress redirect dev eth0

(only do this on toy vm)
