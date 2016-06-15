From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next 00/10] net_sched: defer skb freeing while
 changing qdiscs
Date: Tue, 14 Jun 2016 19:13:31 -0700
Message-ID: <CAM_iQpXD4dC1jEQOAOV0f=BoF5YGHe-fYxudaN_d_a4AgrWeRQ@mail.gmail.com>
References: <1465874519-25494-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f195.google.com ([209.85.161.195]:35254 "EHLO
	mail-yw0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752938AbcFOCNv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2016 22:13:51 -0400
Received: by mail-yw0-f195.google.com with SMTP id v137so986452ywa.2
        for <netdev@vger.kernel.org>; Tue, 14 Jun 2016 19:13:51 -0700 (PDT)
In-Reply-To: <1465874519-25494-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 13, 2016 at 8:21 PM, Eric Dumazet <edumazet@google.com> wrote:
> qdiscs/classes are changed under RTNL protection and often
> while blocking BH and root qdisc spinlock.
>
> When lots of skbs need to be dropped, we free
> them under these locks causing TX/RX freezes,
> and more generally latency spikes.
>
> I saw spikes of 50+ ms on quite fast hardware...
>
> This patch series adds a simple queue protected by RTNL
> where skbs can be placed until RTNL is released.
>
> Note that this might also serve in the future for optional
> reinjection of packets when a qdisc is replaced.

No objection from me. It looks like a good optimization
before we can improve the qdisc root spinlock.

Just one nit: You probably want to keep rtnl_kfree_skbs()
within qdisc layer unless you have any plan to use it
in other places.

Thanks!
