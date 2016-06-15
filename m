From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 00/10] net_sched: defer skb freeing while
 changing qdiscs
Date: Tue, 14 Jun 2016 21:20:40 -0700
Message-ID: <1465964440.7945.190.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1465874519-25494-1-git-send-email-edumazet@google.com>
	 <CAM_iQpXD4dC1jEQOAOV0f=BoF5YGHe-fYxudaN_d_a4AgrWeRQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	"David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35400 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750778AbcFOEUn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 00:20:43 -0400
Received: by mail-pf0-f194.google.com with SMTP id t190so803326pfb.2
        for <netdev@vger.kernel.org>; Tue, 14 Jun 2016 21:20:43 -0700 (PDT)
In-Reply-To: <CAM_iQpXD4dC1jEQOAOV0f=BoF5YGHe-fYxudaN_d_a4AgrWeRQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-06-14 at 19:13 -0700, Cong Wang wrote:

> No objection from me. It looks like a good optimization
> before we can improve the qdisc root spinlock.
> 
> Just one nit: You probably want to keep rtnl_kfree_skbs()
> within qdisc layer unless you have any plan to use it
> in other places.

I do not see other places freeing a lot of skbs under rtnl ;)

As a side effect, using rtnl_kfree_skb() changes call graph given by
drop monitor, so better avoid this unless really needed.
