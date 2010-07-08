From: Karl Hiramoto <karl@hiramoto.org>
Subject: [PATCH v4 6/9] atm/suni.c: call atm_dev_signal_change() when signal changes.
Date: Thu,  8 Jul 2010 10:34:52 +0200
Message-ID: <1278578095-25324-7-git-send-email-karl@hiramoto.org>
References: <1278578095-25324-1-git-send-email-karl@hiramoto.org>
Cc: Karl Hiramoto <karl@hiramoto.org>
To: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	chas@cmf.nrl.navy.mil, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from caiajhbdcagg.dreamhost.com ([208.97.132.66]:57515 "EHLO
	homiemail-a36.g.dreamhost.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755267Ab0GHIfT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jul 2010 04:35:19 -0400
In-Reply-To: <1278578095-25324-1-git-send-email-karl@hiramoto.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Propagate changes to upper atm layer.

Signed-off-by: Karl Hiramoto <karl@hiramoto.org>
---
 drivers/atm/suni.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/atm/suni.c b/drivers/atm/suni.c
index da4b91f..41c56ea 100644
--- a/drivers/atm/suni.c
+++ b/drivers/atm/suni.c
@@ -291,8 +291,9 @@ static int suni_ioctl(struct atm_dev *dev,unsigned int cmd,void __user *arg)
 
 static void poll_los(struct atm_dev *dev)
 {
-	dev->signal = GET(RSOP_SIS) & SUNI_RSOP_SIS_LOSV ? ATM_PHY_SIG_LOST :
-	  ATM_PHY_SIG_FOUND;
+	atm_dev_signal_change(dev,
+		GET(RSOP_SIS) & SUNI_RSOP_SIS_LOSV ?
+		ATM_PHY_SIG_LOST : ATM_PHY_SIG_FOUND);
 }
 
 
-- 
1.7.1

