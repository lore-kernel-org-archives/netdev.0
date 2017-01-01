From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 06/12] qede - mark SKB as encapsulated
Date: Sun, 1 Jan 2017 13:57:05 +0200
Message-ID: <1483271831-25890-7-git-send-email-Yuval.Mintz@cavium.com>
References: <1483271831-25890-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Manish Chopra <Manish.Chopra@cavium.com>,
        Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:53882 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932144AbdAAL6S (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Jan 2017 06:58:18 -0500
In-Reply-To: <1483271831-25890-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Chopra <Manish.Chopra@cavium.com>

When driver receives a recognized encapsulated packet it needs
to set the skb->encapsulation field as well.

Signed-off-by: Manish Chopra <Manish.Chopra@cavium.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qede/qede_fp.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qede/qede_fp.c b/drivers/net/ethernet/qlogic/qede/qede_fp.c
index a06acab..dddae1e 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_fp.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_fp.c
@@ -607,8 +607,10 @@ static void qede_set_skb_csum(struct sk_buff *skb, u8 csum_flag)
 	if (csum_flag & QEDE_CSUM_UNNECESSARY)
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 
-	if (csum_flag & QEDE_TUNN_CSUM_UNNECESSARY)
+	if (csum_flag & QEDE_TUNN_CSUM_UNNECESSARY) {
 		skb->csum_level = 1;
+		skb->encapsulation = 1;
+	}
 }
 
 static inline void qede_skb_receive(struct qede_dev *edev,
-- 
1.9.3
