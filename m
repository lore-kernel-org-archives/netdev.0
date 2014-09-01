From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv2 net 5/6] cxgb4: Avoid dumping Write-only registers in register dump
Date: Mon,  1 Sep 2014 19:54:59 +0530
Message-ID: <1409581500-11264-6-git-send-email-hariprasad@chelsio.com>
References: <1409581500-11264-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	kumaras@chelsio.com, anish@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:51407
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753923AbaIAOTg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2014 10:19:36 -0400
In-Reply-To: <1409581500-11264-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Avoid dumping MPS_RPLC_MAP_CTL for reg dumps; this is a Write-Only register.
Reading this register may cause MPS TCAM corruption.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index cf387ae..1b5020a 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -1763,7 +1763,8 @@ static void get_regs(struct net_device *dev, struct ethtool_regs *regs,
 		0xd004, 0xd03c,
 		0xdfc0, 0xdfe0,
 		0xe000, 0xea7c,
-		0xf000, 0x11190,
+		0xf000, 0x11110,
+		0x11118, 0x11190,
 		0x19040, 0x1906c,
 		0x19078, 0x19080,
 		0x1908c, 0x19124,
@@ -1970,7 +1971,8 @@ static void get_regs(struct net_device *dev, struct ethtool_regs *regs,
 		0xd004, 0xd03c,
 		0xdfc0, 0xdfe0,
 		0xe000, 0x11088,
-		0x1109c, 0x1117c,
+		0x1109c, 0x11110,
+		0x11118, 0x1117c,
 		0x11190, 0x11204,
 		0x19040, 0x1906c,
 		0x19078, 0x19080,
-- 
1.7.1
