From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next 4/4] stmmac: use one memset() to reset TDES01
Date: Fri, 17 Sep 2010 15:23:42 +0200
Message-ID: <1284729822-29176-4-git-send-email-peppe.cavallaro@st.com>
References: <1284729822-29176-1-git-send-email-peppe.cavallaro@st.com>
 <1284729822-29176-2-git-send-email-peppe.cavallaro@st.com>
 <1284729822-29176-3-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog108.obsmtp.com ([207.126.144.125]:54492 "EHLO
	eu1sys200aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754081Ab0IQNYZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Sep 2010 09:24:25 -0400
Received: from zeta.dmz-eu.st.com (ns2.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id CE33397
	for <netdev@vger.kernel.org>; Fri, 17 Sep 2010 13:24:21 +0000 (GMT)
Received: from mail3.ctn.st.com (mail3.ctn.st.com [164.130.116.150])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 9B82C2B1F
	for <netdev@vger.kernel.org>; Fri, 17 Sep 2010 13:24:21 +0000 (GMT)
In-Reply-To: <1284729822-29176-3-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use one memset() to reset all TDES01 fields instead
of one by one to reduce number of instructions.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/stmmac/enh_desc.c  |    2 +-
 drivers/net/stmmac/norm_desc.c |   17 +----------------
 2 files changed, 2 insertions(+), 17 deletions(-)

diff --git a/drivers/net/stmmac/enh_desc.c b/drivers/net/stmmac/enh_desc.c
index 77ff88c..5d1471d 100644
--- a/drivers/net/stmmac/enh_desc.c
+++ b/drivers/net/stmmac/enh_desc.c
@@ -284,7 +284,7 @@ static void enh_desc_release_tx_desc(struct dma_desc *p)
 {
 	int ter = p->des01.etx.end_ring;
 
-	memset(p, 0, sizeof(struct dma_desc));
+	memset(p, 0, offsetof(struct dma_desc, des2));
 	p->des01.etx.end_ring = ter;
 }
 
diff --git a/drivers/net/stmmac/norm_desc.c b/drivers/net/stmmac/norm_desc.c
index 51f4440..0dce90c 100644
--- a/drivers/net/stmmac/norm_desc.c
+++ b/drivers/net/stmmac/norm_desc.c
@@ -174,22 +174,7 @@ static void ndesc_release_tx_desc(struct dma_desc *p)
 {
 	int ter = p->des01.tx.end_ring;
 
-	/* clean field used within the xmit */
-	p->des01.tx.first_segment = 0;
-	p->des01.tx.last_segment = 0;
-	p->des01.tx.buffer1_size = 0;
-
-	/* clean status reported */
-	p->des01.tx.error_summary = 0;
-	p->des01.tx.underflow_error = 0;
-	p->des01.tx.no_carrier = 0;
-	p->des01.tx.loss_carrier = 0;
-	p->des01.tx.excessive_deferral = 0;
-	p->des01.tx.excessive_collisions = 0;
-	p->des01.tx.late_collision = 0;
-	p->des01.tx.heartbeat_fail = 0;
-	p->des01.tx.deferred = 0;
-
+	memset(p, 0, offsetof(struct dma_desc, des2));
 	/* set termination field */
 	p->des01.tx.end_ring = ter;
 }
-- 
1.7.0.4

