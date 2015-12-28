From: Sathya Perla <sathya.perla@avagotech.com>
Subject: [PATCH net-next v2 02/10] be2net: avoid configuring VEPA mode on BE3
Date: Mon, 28 Dec 2015 01:49:16 -0500
Message-ID: <1451285364-9074-3-git-send-email-sathya.perla@avagotech.com>
References: <1451285364-9074-1-git-send-email-sathya.perla@avagotech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmrelayp1.emulex.com ([138.239.112.140]:54927 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751011AbbL1Gtb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Dec 2015 01:49:31 -0500
In-Reply-To: <1451285364-9074-1-git-send-email-sathya.perla@avagotech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Suresh Reddy <suresh.reddy@avagotech.com>

BE3 chip doesn't support VEPA mode.

Signed-off-by: Suresh Reddy <suresh.reddy@avagotech.com>
Signed-off-by: Sathya Perla <sathya.perla@avagotech.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 34e324f..2f76cbe 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -5108,6 +5108,9 @@ static int be_ndo_bridge_setlink(struct net_device *dev, struct nlmsghdr *nlh,
 			return -EINVAL;
 
 		mode = nla_get_u16(attr);
+		if (BE3_chip(adapter) && mode == BRIDGE_MODE_VEPA)
+			return -EOPNOTSUPP;
+
 		if (mode != BRIDGE_MODE_VEPA && mode != BRIDGE_MODE_VEB)
 			return -EINVAL;
 
-- 
2.4.1
