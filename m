From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] netem: fix a use after free
Date: Mon, 20 Jun 2016 14:59:40 -0700
Message-ID: <1466459980.6850.20.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	WANG Cong <xiyou.wangcong@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33022 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754578AbcFTV7s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 17:59:48 -0400
Received: by mail-pf0-f193.google.com with SMTP id c74so12413626pfb.0
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2016 14:59:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

If the packet was dropped by lower qdisc, then we must not
access it later.

Save qdisc_pkt_len(skb) in a temp variable.

Fixes: 2ccccf5fb43f ("net_sched: update hierarchical backlog too")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: WANG Cong <xiyou.wangcong@gmail.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>
---
 net/sched/sch_netem.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)
