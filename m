From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/3] inetpeer: Mark metrics as "new" in fresh inetpeer
 entries.
Date: Thu, 27 Jan 2011 15:01:37 -0800 (PST)
Message-ID: <20110127.150137.70190267.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36919
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753802Ab1A0XBC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jan 2011 18:01:02 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 3407824C089
	for <netdev@vger.kernel.org>; Thu, 27 Jan 2011 15:01:38 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Set the RTAX_LOCKED metric to INETPEER_METRICS_NEW (basically,
all ones) on fresh inetpeer entries.

This way code can determine if default metrics have been loaded
in from a routing table entry already.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/inetpeer.h |    7 +++++++
 net/ipv4/inetpeer.c    |    1 +
 2 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/include/net/inetpeer.h b/include/net/inetpeer.h
index 2af0c63..61f2c66 100644
--- a/include/net/inetpeer.h
+++ b/include/net/inetpeer.h
@@ -51,6 +51,13 @@ struct inet_peer {
 
 void			inet_initpeers(void) __init;
 
+#define INETPEER_METRICS_NEW	(~(u32) 0)
+
+static inline bool inet_metrics_new(const struct inet_peer *p)
+{
+	return p->metrics[RTAX_LOCK-1] == INETPEER_METRICS_NEW;
+}
+
 /* can be called with or without local BH being disabled */
 struct inet_peer	*inet_getpeer(struct inetpeer_addr *daddr, int create);
 
diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index a96e656..b6513b1 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -512,6 +512,7 @@ struct inet_peer *inet_getpeer(struct inetpeer_addr *daddr, int create)
 		atomic_set(&p->rid, 0);
 		atomic_set(&p->ip_id_count, secure_ip_id(daddr->a4));
 		p->tcp_ts_stamp = 0;
+		p->metrics[RTAX_LOCK-1] = INETPEER_METRICS_NEW;
 		INIT_LIST_HEAD(&p->unused);
 
 
-- 
1.7.3.4

