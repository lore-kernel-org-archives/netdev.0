From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 4/4] cxgb4: Update firmware version after flashing it via ethtool
Date: Wed,  3 Dec 2014 19:32:54 +0530
Message-ID: <1417615374-12961-5-git-send-email-hariprasad@chelsio.com>
References: <1417615374-12961-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:57244
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752523AbaLCN5S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 08:57:18 -0500
In-Reply-To: <1417615374-12961-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After successfully loading new firmware, reload the new firmware's version
number information so "ethtool -i", etc. will report the right value

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 3f8876f..a9323bd 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -1213,6 +1213,8 @@ out:
 	if (ret)
 		dev_err(adap->pdev_dev, "firmware download failed, error %d\n",
 			ret);
+	else
+		ret = t4_get_fw_version(adap, &adap->params.fw_vers);
 	return ret;
 }
 
-- 
1.7.1
