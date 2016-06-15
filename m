From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next 00/10] net_sched: defer skb freeing while
 changing qdiscs
Date: Wed, 15 Jun 2016 07:43:03 -0400
Message-ID: <57613F47.9060106@mojatatu.com>
References: <1465874519-25494-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>,
	"David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:35081 "EHLO
	mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752789AbcFOLnG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 07:43:06 -0400
Received: by mail-io0-f194.google.com with SMTP id n127so2752085iof.2
        for <netdev@vger.kernel.org>; Wed, 15 Jun 2016 04:43:05 -0700 (PDT)
In-Reply-To: <1465874519-25494-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-06-13 11:21 PM, Eric Dumazet wrote:
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
>

Nice optimization Eric.

cheers,
jamal
