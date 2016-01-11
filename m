From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next v5 04/10] benet: add rtnl lock protection around be_open in be_resume
Date: Mon, 11 Jan 2016 13:17:25 +0100
Message-ID: <1452514651-15445-5-git-send-email-hannes@stressinduktion.org>
References: <1452514651-15445-1-git-send-email-hannes@stressinduktion.org>
Cc: jesse@kernel.org, Sathya Perla <sathya.perla@avagotech.com>,
	Ajit Khaparde <ajit.khaparde@avagotech.com>,
	Padmanabh Ratnakar <padmanabh.ratnakar@avagotech.com>,
	Sriharsha Basavapatna <sriharsha.basavapatna@avagotech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:55372 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932827AbcAKMRo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 07:17:44 -0500
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by mailout.nyi.internal (Postfix) with ESMTP id C952320B1F
	for <netdev@vger.kernel.org>; Mon, 11 Jan 2016 07:17:43 -0500 (EST)
In-Reply-To: <1452514651-15445-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: Sathya Perla <sathya.perla@avagotech.com>
Cc: Ajit Khaparde <ajit.khaparde@avagotech.com>
Cc: Padmanabh Ratnakar <padmanabh.ratnakar@avagotech.com>
Cc: Sriharsha Basavapatna <sriharsha.basavapatna@avagotech.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 drivers/net/ethernet/emulex/benet/be_main.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index f99de3657ce3b5..3200f48ddd5a68 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -4846,11 +4846,12 @@ static int be_resume(struct be_adapter *adapter)
 	if (status)
 		return status;
 
-	if (netif_running(netdev)) {
+	rtnl_lock();
+	if (netif_running(netdev))
 		status = be_open(netdev);
-		if (status)
-			return status;
-	}
+	rtnl_unlock();
+	if (status)
+		return status;
 
 	netif_device_attach(netdev);
 
-- 
2.5.0
