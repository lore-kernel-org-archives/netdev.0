From: fgao@ikuai8.com
Subject: [PATCH net-next 1/1] driver: ipvlan: Remove unnecessary ipvlan NULL check in ipvlan_count_rx
Date: Mon, 19 Dec 2016 09:24:39 +0800
Message-ID: <1482110679-1967-1-git-send-email-fgao@ikuai8.com>
Cc: Gao Feng <fgao@ikuai8.com>
To: davem@davemloft.net, maheshb@google.com, edumazet@google.com,
        netdev@vger.kernel.org, gfree.wind@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from SMTPBG352.QQ.COM ([183.57.50.167]:36270 "EHLO smtpbg352.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751171AbcLSBZW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 18 Dec 2016 20:25:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

There are three functions which would invoke the ipvlan_count_rx. They
are ipvlan_process_multicast, ipvlan_rcv_frame, and ipvlan_nf_input.
The former two functions already use the ipvlan directly before
ipvlan_count_rx, and ipvlan_nf_input gets the ipvlan from
ipvl_addr->master, it is not possible to be NULL too.
So the ipvlan pointer check is unnecessary in ipvlan_count_rx.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
---
 drivers/net/ipvlan/ipvlan_core.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/ipvlan/ipvlan_core.c b/drivers/net/ipvlan/ipvlan_core.c
index b4e9907..082f9f1 100644
--- a/drivers/net/ipvlan/ipvlan_core.c
+++ b/drivers/net/ipvlan/ipvlan_core.c
@@ -19,9 +19,6 @@ void ipvlan_init_secret(void)
 static void ipvlan_count_rx(const struct ipvl_dev *ipvlan,
 			    unsigned int len, bool success, bool mcast)
 {
-	if (!ipvlan)
-		return;
-
 	if (likely(success)) {
 		struct ipvl_pcpu_stats *pcptr;
 
-- 
1.9.1
