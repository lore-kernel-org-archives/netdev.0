From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [PATCH] neigh: check error pointer instead of NULL for ipv4_neigh_lookup()
Date: Wed, 24 Sep 2014 17:07:53 -0700
Message-ID: <1411603673-19084-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:38801 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750793AbaIYAIO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2014 20:08:14 -0400
Received: by mail-pd0-f169.google.com with SMTP id fp1so5399880pdb.14
        for <netdev@vger.kernel.org>; Wed, 24 Sep 2014 17:08:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes: commit f187bc6efb7250afee0e2009b6106 ("ipv4: No need to set generic neighbour pointer")
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/ipv4/route.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 173e7ea..cbadb94 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -746,7 +746,7 @@ static void __ip_do_redirect(struct rtable *rt, struct sk_buff *skb, struct flow
 	}
 
 	n = ipv4_neigh_lookup(&rt->dst, NULL, &new_gw);
-	if (n) {
+	if (!IS_ERR(n)) {
 		if (!(n->nud_state & NUD_VALID)) {
 			neigh_event_send(n, NULL);
 		} else {
-- 
1.8.3.1
