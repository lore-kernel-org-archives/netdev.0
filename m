From: Karl Hiramoto <karl@hiramoto.org>
Subject: [PATCH 5/6] atm/suni.c: call atm_dev_signal_change() when signal changes.
Date: Fri,  2 Jul 2010 19:47:09 +0200
Message-ID: <1278092830-10473-6-git-send-email-karl@hiramoto.org>
References: <1278092830-10473-1-git-send-email-karl@hiramoto.org>
Cc: nathan@traverse.com.au, Karl Hiramoto <karl@hiramoto.org>
To: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	chas@cmf.nrl.navy.mil
Return-path: <netdev-owner@vger.kernel.org>
Received: from hapkido.dreamhost.com ([66.33.216.122]:47540 "EHLO
	hapkido.dreamhost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755624Ab0GBRsx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jul 2010 13:48:53 -0400
Received: from homiemail-a32.g.dreamhost.com (caiajhbdcbef.dreamhost.com [208.97.132.145])
	by hapkido.dreamhost.com (Postfix) with ESMTP id 3351217974A
	for <netdev@vger.kernel.org>; Fri,  2 Jul 2010 10:48:53 -0700 (PDT)
In-Reply-To: <1278092830-10473-1-git-send-email-karl@hiramoto.org>
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

