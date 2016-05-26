From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net 1/8] qede: Fix VF minimum BW setting
Date: Thu, 26 May 2016 11:01:17 +0300
Message-ID: <1464249684-976-2-git-send-email-Yuval.Mintz@qlogic.com>
References: <1464249684-976-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:3135 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753202AbcEZIBi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2016 04:01:38 -0400
In-Reply-To: <1464249684-976-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

VF is currently ignoring the minimum provided by the API,
mistakenly using the maximum for minimum as well.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qede/qede_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index 337e839..3bb1428 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -1824,7 +1824,7 @@ static int qede_set_vf_rate(struct net_device *dev, int vfidx,
 {
 	struct qede_dev *edev = netdev_priv(dev);
 
-	return edev->ops->iov->set_rate(edev->cdev, vfidx, max_tx_rate,
+	return edev->ops->iov->set_rate(edev->cdev, vfidx, min_tx_rate,
 					max_tx_rate);
 }
 
-- 
1.9.3
