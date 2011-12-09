From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 2/13] inet_diag: Reduce the number of args for bytecode run
 routine
Date: Fri, 09 Dec 2011 20:21:34 +0400
Message-ID: <4EE2358E.9040205@parallels.com>
References: <4EE23561.5020804@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:7916 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750798Ab1LIQVj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Dec 2011 11:21:39 -0500
In-Reply-To: <4EE23561.5020804@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 net/ipv4/inet_diag.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index a247f85..bd3f661 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -355,9 +355,12 @@ static int bitstring_match(const __be32 *a1, const __be32 *a2, int bits)
 }
 
 
-static int inet_diag_bc_run(const void *bc, int len,
-			    const struct inet_diag_entry *entry)
+static int inet_diag_bc_run(const struct nlattr *_bc,
+		const struct inet_diag_entry *entry)
 {
+	const void *bc = nla_data(_bc);
+	int len = nla_len(_bc);
+
 	while (len > 0) {
 		int yes = 1;
 		const struct inet_diag_bc_op *op = bc;
@@ -512,7 +515,7 @@ static int inet_csk_diag_dump(struct sock *sk,
 		entry.dport = ntohs(inet->inet_dport);
 		entry.userlocks = sk->sk_userlocks;
 
-		if (!inet_diag_bc_run(nla_data(bc), nla_len(bc), &entry))
+		if (!inet_diag_bc_run(bc, &entry))
 			return 0;
 	}
 
@@ -547,7 +550,7 @@ static int inet_twsk_diag_dump(struct inet_timewait_sock *tw,
 		entry.dport = ntohs(tw->tw_dport);
 		entry.userlocks = 0;
 
-		if (!inet_diag_bc_run(nla_data(bc), nla_len(bc), &entry))
+		if (!inet_diag_bc_run(bc, &entry))
 			return 0;
 	}
 
@@ -668,8 +671,7 @@ static int inet_diag_dump_reqs(struct sk_buff *skb, struct sock *sk,
 					&ireq->rmt_addr;
 				entry.dport = ntohs(ireq->rmt_port);
 
-				if (!inet_diag_bc_run(nla_data(bc),
-						      nla_len(bc), &entry))
+				if (!inet_diag_bc_run(bc, &entry))
 					continue;
 			}
 
-- 
1.5.5.6
