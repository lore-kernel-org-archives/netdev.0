From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH 1/3] cxgb4: fix initial addition of MAC address
Date: Tue, 18 May 2010 13:07:11 -0700
Message-ID: <1274213233-26309-1-git-send-email-dm@chelsio.com>
Cc: Dimitris Michailidis <dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:22285 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752801Ab0ERUHP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 16:07:15 -0400
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o4IK7Eqg008162
	for <netdev@vger.kernel.org>; Tue, 18 May 2010 13:07:14 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The call to add the MAC address during link initialization wasn't adding the
address to one of the HW tables.  Fix.

Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
---
 drivers/net/cxgb4/cxgb4_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/cxgb4/cxgb4_main.c b/drivers/net/cxgb4/cxgb4_main.c
index 90d375b..1f59971 100644
--- a/drivers/net/cxgb4/cxgb4_main.c
+++ b/drivers/net/cxgb4/cxgb4_main.c
@@ -315,7 +315,7 @@ static int link_start(struct net_device *dev)
 	if (ret == 0) {
 		ret = t4_change_mac(pi->adapter, 0, pi->viid,
 				    pi->xact_addr_filt, dev->dev_addr, true,
-				    false);
+				    true);
 		if (ret >= 0) {
 			pi->xact_addr_filt = ret;
 			ret = 0;
-- 
1.5.4

