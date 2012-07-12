From: Karsten Keil <kkeil@linux-pingi.de>
Subject: [PATCH] ISDN:Add check for return value of pnp_activate_dev()
Date: Thu, 12 Jul 2012 19:01:10 +0200
Message-ID: <1342112470-12301-1-git-send-email-kkeil@linux-pingi.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.9]:61042 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934096Ab2GLRBN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 13:01:13 -0400
Received: from pingi6.linux-pingi.de (pingi6.linux-pingi.de [10.23.200.6])
	by mailone.linux-pingi.de (Postfix) with ESMTPS id 55123B004A
	for <netdev@vger.kernel.org>; Thu, 12 Jul 2012 19:01:09 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

pnp_activate_dev() return value needs to be checked to make sure that
following calls calls to the PNP functions do work correctly.
Fix for report #44491 on bugzilla.kernel.org.

Signed-off-by: Karsten Keil <kkeil@linux-pingi.de>
---
 drivers/isdn/hisax/isurf.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/isdn/hisax/isurf.c b/drivers/isdn/hisax/isurf.c
index ea27172..c1530fe 100644
--- a/drivers/isdn/hisax/isurf.c
+++ b/drivers/isdn/hisax/isurf.c
@@ -231,6 +231,11 @@ setup_isurf(struct IsdnCard *card)
 				}
 				pnp_disable_dev(pnp_d);
 				err = pnp_activate_dev(pnp_d);
+				if (err < 0) {
+					pr_warn("%s: pnp_activate_dev ret=%d\n",
+						__func__, err);
+					return 0;
+				}
 				cs->hw.isurf.reset = pnp_port_start(pnp_d, 0);
 				cs->hw.isurf.phymem = pnp_mem_start(pnp_d, 1);
 				cs->irq = pnp_irq(pnp_d, 0);
-- 
1.7.7
