From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next 1/4] udp_offload: simplify error path
Date: Thu,  7 Jul 2016 17:58:47 +0200
Message-ID: <628153aba10ae0dae9090e7547f14520f16972e2.1467907022.git.pabeni@redhat.com>
References: <cover.1467907022.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Jesse Gross <jesse@kernel.org>,
	Tom Herbert <tom@herbertland.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Jiri Benc <jbenc@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41070 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753045AbcGGQAq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jul 2016 12:00:46 -0400
In-Reply-To: <cover.1467907022.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can remove an unconditional jump, checking for the error
condition instead of checking for success

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 net/ipv4/udp_offload.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index 81f253b..9c37338 100644
--- a/net/ipv4/udp_offload.c
+++ b/net/ipv4/udp_offload.c
@@ -268,11 +268,9 @@ struct sk_buff **udp_gro_receive(struct sk_buff **head, struct sk_buff *skb,
 	rcu_read_lock();
 	sk = (*lookup)(skb, uh->source, uh->dest);
 
-	if (sk && udp_sk(sk)->gro_receive)
-		goto unflush;
-	goto out_unlock;
+	if (!sk || !udp_sk(sk)->gro_receive)
+		goto out_unlock;
 
-unflush:
 	flush = 0;
 
 	for (p = *head; p; p = p->next) {
-- 
1.8.3.1
