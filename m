From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] dccp: fix a memleak that dccp_ipv4 doesn't put reqsk properly
Date: Wed, 26 Jul 2017 14:19:46 +0800
Message-ID: <795235abacd1bbf9f1144f3094b1f604d513cf65.1501049986.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:38715 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751697AbdGZGTz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2017 02:19:55 -0400
Received: by mail-pg0-f65.google.com with SMTP id 125so2990703pgi.5
        for <netdev@vger.kernel.org>; Tue, 25 Jul 2017 23:19:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch "dccp: fix a memleak that dccp_ipv6 doesn't put reqsk
properly" fixed reqsk refcnt leak for dccp_ipv6. The same issue
exists on dccp_ipv4.

This patch is to fix it for dccp_ipv4.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/dccp/ipv4.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index f85d901..1b202f1 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -631,6 +631,7 @@ int dccp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 		goto drop_and_free;
 
 	inet_csk_reqsk_queue_hash_add(sk, req, DCCP_TIMEOUT_INIT);
+	reqsk_put(req);
 	return 0;
 
 drop_and_free:
-- 
2.1.0
