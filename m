From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] net/hsr: Remove unused but set variable
Date: Tue, 18 Oct 2016 09:07:29 +0200
Message-ID: <20161018070729.10110-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Arvid Brodin <arvid.brodin@alten.se>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:50704 "EHLO mail.zhinst.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753616AbcJRHHf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 18 Oct 2016 03:07:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the unused but set variable master_dev in check_local_dest to fix
the following GCC warning when building with 'W=1':

  net/hsr/hsr_forward.c: In function ‘check_local_dest’:
  net/hsr/hsr_forward.c:303:21: warning: variable ‘master_dev’ set but not used [-Wunused-but-set-variable]

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 net/hsr/hsr_forward.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/net/hsr/hsr_forward.c b/net/hsr/hsr_forward.c
index 5ee1d43f1310..4ebe2aa3e7d3 100644
--- a/net/hsr/hsr_forward.c
+++ b/net/hsr/hsr_forward.c
@@ -300,10 +300,6 @@ static void hsr_forward_do(struct hsr_frame_info *frame)
 static void check_local_dest(struct hsr_priv *hsr, struct sk_buff *skb,
 			     struct hsr_frame_info *frame)
 {
-	struct net_device *master_dev;
-
-	master_dev = hsr_port_get_hsr(hsr, HSR_PT_MASTER)->dev;
-
 	if (hsr_addr_is_self(hsr, eth_hdr(skb)->h_dest)) {
 		frame->is_local_exclusive = true;
 		skb->pkt_type = PACKET_HOST;
-- 
2.9.0
