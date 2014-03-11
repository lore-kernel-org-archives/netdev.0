From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 0/2] pkt_sched: allow scheduling points
Date: Mon, 10 Mar 2014 17:11:41 -0700
Message-ID: <1394496703-9278-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f74.google.com ([209.85.216.74]:47473 "EHLO
	mail-qa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752562AbaCKAMD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 20:12:03 -0400
Received: by mail-qa0-f74.google.com with SMTP id w5so1040064qac.3
        for <netdev@vger.kernel.org>; Mon, 10 Mar 2014 17:12:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have seen delays of more than 50ms in class or qdisc dumps, in case
device is under high TX stress, even with the prior 4KB per skb limit.

With the new 16KB limit, this could translate to 200ms delays.

Add cond_resched() to give a chance to higher prio tasks to get cpu.

But before doing so, we need to remove the rcu locking from tc_dump_qdisc()
as David spotted.

Eric Dumazet (2):
  pkt_sched: do not use rcu in tc_dump_qdisc()
  pkt_sched: add cond_resched() to class and qdisc dump

 net/sched/sch_api.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

-- 
1.9.0.279.gdc9e3eb
