From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH 2/3] be2net: restrict MODIFY_EQ_DELAY cmd to a max of 8 EQs
Date: Fri, 20 Mar 2015 06:28:24 -0400
Message-ID: <1426847305-23008-3-git-send-email-sathya.perla@emulex.com>
References: <1426847305-23008-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.emulex.com ([138.239.224.100]:20338 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751449AbbCTKZN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 06:25:13 -0400
In-Reply-To: <1426847305-23008-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Suresh Reddy <Suresh.Reddy@emulex.com>

Issuing this cmd for more than 8 EQs does not have the intended effect
even on BEx and Skyhawk-R.

This patch fixes this by issuing this cmd for upto 8 EQs at a time.
Signed-off-by: Suresh Reddy <Suresh.Reddy@emulex.com>

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c | 14 +++++---------
 1 file changed, 5 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 3e894f4..7f05f30 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -1902,15 +1902,11 @@ int be_cmd_modify_eqd(struct be_adapter *adapter, struct be_set_eqd *set_eqd,
 {
 	int num_eqs, i = 0;
 
-	if (lancer_chip(adapter) && num > 8) {
-		while (num) {
-			num_eqs = min(num, 8);
-			__be_cmd_modify_eqd(adapter, &set_eqd[i], num_eqs);
-			i += num_eqs;
-			num -= num_eqs;
-		}
-	} else {
-		__be_cmd_modify_eqd(adapter, set_eqd, num);
+	while (num) {
+		num_eqs = min(num, 8);
+		__be_cmd_modify_eqd(adapter, &set_eqd[i], num_eqs);
+		i += num_eqs;
+		num -= num_eqs;
 	}
 
 	return 0;
-- 
2.2.0
