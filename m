From: Zhao Hongjiang <zhaohongjiang@huawei.com>
Subject: [PATCH 1/5] net: ipv4: using strlcpy instead of strncpy
Date: Thu, 20 Jun 2013 18:49:41 +0800
Message-ID: <1371725385-11540-1-git-send-email-zhaohongjiang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kuznet@ms2.inr.ac.ru>, <jmorris@namei.org>,
	<yoshfuji@linux-ipv6.org>, <kaber@trash.net>,
	<netdev@vger.kernel.org>, Zhao Hongjiang <zhaohongjiang@huawei.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:3890 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754713Ab3FTKvA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jun 2013 06:51:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

for NUL terminated string, need alway set '\0' in the end.

Signed-off-by: Zhao Hongjiang <zhaohongjiang@huawei.com>
---
 net/ipv4/tcp_cong.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
index 019c238..3280234 100644
--- a/net/ipv4/tcp_cong.c
+++ b/net/ipv4/tcp_cong.c
@@ -170,7 +170,7 @@ void tcp_get_default_congestion_control(char *name)
 
 	rcu_read_lock();
 	ca = list_entry(tcp_cong_list.next, struct tcp_congestion_ops, list);
-	strncpy(name, ca->name, TCP_CA_NAME_MAX);
+	strlcpy(name, ca->name, sizeof(name));
 	rcu_read_unlock();
 }
 
-- 
1.7.1
