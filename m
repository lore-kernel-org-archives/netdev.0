From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net-next 4/4] net/sched: act_mirred: Implement ingress
 actions
Date: Mon, 26 Sep 2016 03:35:04 +0200
Message-ID: <20160926013504.GA1959@breakpoint.cc>
References: <1474550512-7552-1-git-send-email-shmulik.ladkani@gmail.com>
 <1474550512-7552-5-git-send-email-shmulik.ladkani@gmail.com>
 <4387324a-de66-aa1b-86f0-1a9a2f8294f5@mojatatu.com>
 <20160923081106.73fb48df@halley>
 <0037729a-a3fc-c1c9-a620-905c73e0b9d4@mojatatu.com>
 <20160923184030.75124289@halley>
 <6d2bd45a-a8a0-846d-5934-5e246522cab8@mojatatu.com>
 <20160925203309.633cf3d5@halley>
 <20160925183136.GA3307@breakpoint.cc>
 <54535aa0-cafd-86ec-1f6c-64c974a5eed6@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        WANG Cong <xiyou.wangcong@gmail.com>,
        Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:47304 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S936362AbcIZBfM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 25 Sep 2016 21:35:12 -0400
Content-Disposition: inline
In-Reply-To: <54535aa0-cafd-86ec-1f6c-64c974a5eed6@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> On 16-09-25 02:31 PM, Florian Westphal wrote:
> >Shmulik Ladkani <shmulik.ladkani@gmail.com> wrote:
> >>We can later address any loop-detection improvements in mirred.
> >>WDYT?
> >
> >You can address this after fixing infamous spinlock recursion hard
> >lockup (which has existed forever):
> >
> >tc qdisc add dev eth0 root handle 1: prio
> >tc filter add dev eth0 parent 1: protocol ip u32 match u32 0 0 flowid
> >1:2 action mirred egress redirect dev eth0
> >
> >(only do this on toy vm)
> >
> 
> Realize didnt respond to this. Seems very simple to fix:
> if skb->dev->ifindex and m->tcfm_dev->ifindex are the
> same, then you can drop the packet.

Yes, but I think we get same issue when we deal with stacked
interfaces, and redirect is to e.g. vlan on top of physical device.

And we have such loops even without tc, for instance when placing
both veth ends in same bridge :-(
