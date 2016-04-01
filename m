From: Jisheng Zhang <jszhang@marvell.com>
Subject: [PATCH] net: mvneta: use cache_line_size() to get cacheline size
Date: Fri, 1 Apr 2016 17:12:49 +0800
Message-ID: <1459501969-7083-1-git-send-email-jszhang@marvell.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	Jisheng Zhang <jszhang@marvell.com>
To: <davem@davemloft.net>, <mw@semihalf.com>,
	<thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016f401.pphosted.com ([67.231.148.174]:29724 "EHLO
	mx0a-0016f401.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752460AbcDAJRF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 05:17:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

L1_CACHE_BYTES may not be the real cacheline size, use cache_line_size
to determine the cacheline size in runtime.

Signed-off-by: Jisheng Zhang <jszhang@marvell.com>
Suggested-by: Marcin Wojtas <mw@semihalf.com>
---
 drivers/net/ethernet/marvell/mvneta.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 5880871..b1db000 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -299,7 +299,7 @@
 #define MVNETA_RX_PKT_SIZE(mtu) \
 	ALIGN((mtu) + MVNETA_MH_SIZE + MVNETA_VLAN_TAG_LEN + \
 	      ETH_HLEN + ETH_FCS_LEN,			     \
-	      L1_CACHE_BYTES)
+	      cache_line_size())
 
 #define IS_TSO_HEADER(txq, addr) \
 	((addr >= txq->tso_hdrs_phys) && \
-- 
2.8.0.rc3
