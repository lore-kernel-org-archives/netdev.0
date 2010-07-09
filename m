From: Karl Hiramoto <karl@hiramoto.org>
Subject: [PATCH v5 6/9] atm/suni.c: call atm_dev_signal_change() when signal changes.
Date: Fri,  9 Jul 2010 08:55:35 +0200
Message-ID: <1278658538-6769-7-git-send-email-karl@hiramoto.org>
References: <1278658538-6769-1-git-send-email-karl@hiramoto.org>
Cc: Karl Hiramoto <karl@hiramoto.org>
To: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	chas@cmf.nrl.navy.mil, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from caiajhbdccac.dreamhost.com ([208.97.132.202]:35237 "EHLO
	homiemail-a64.g.dreamhost.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753820Ab0GIGz7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jul 2010 02:55:59 -0400
In-Reply-To: <1278658538-6769-1-git-send-email-karl@hiramoto.org>
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

