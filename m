From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] inet: add a schedule point in inet_twsk_purge()
Date: Wed, 18 Mar 2015 17:40:51 -0700
Message-ID: <1426725651.25985.5.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:35602 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751563AbbCSAkx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2015 20:40:53 -0400
Received: by ieclw3 with SMTP id lw3so53308395iec.2
        for <netdev@vger.kernel.org>; Wed, 18 Mar 2015 17:40:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

On a large hash table, we can easily spend seconds to
walk over all entries. Add a cond_resched() to yield
cpu if necessary.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/inet_timewait_sock.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv4/inet_timewait_sock.c b/net/ipv4/inet_timewait_sock.c
index 86ebf020925bd0944e05b912f31e6d694d4c0219..f38e387448fb5596c64cdcb07e7cb06d3e624451 100644
--- a/net/ipv4/inet_timewait_sock.c
+++ b/net/ipv4/inet_timewait_sock.c
@@ -487,6 +487,7 @@ void inet_twsk_purge(struct inet_hashinfo *hashinfo,
 	for (slot = 0; slot <= hashinfo->ehash_mask; slot++) {
 		struct inet_ehash_bucket *head = &hashinfo->ehash[slot];
 restart_rcu:
+		cond_resched();
 		rcu_read_lock();
 restart:
 		sk_nulls_for_each_rcu(sk, node, &head->chain) {
