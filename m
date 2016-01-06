From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next v3 4/8] benet: add rtnl lock protection around be_open in be_resume
Date: Thu,  7 Jan 2016 00:39:27 +0100
Message-ID: <1452123571-19140-5-git-send-email-hannes@stressinduktion.org>
References: <1452123571-19140-1-git-send-email-hannes@stressinduktion.org>
Cc: jesse@kernel.org, Sathya Perla <sathya.perla@avagotech.com>,
	Ajit Khaparde <ajit.khaparde@avagotech.com>,
	Padmanabh Ratnakar <padmanabh.ratnakar@avagotech.com>,
	Sriharsha Basavapatna <sriharsha.basavapatna@avagotech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:39256 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752568AbcAFXjq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 18:39:46 -0500
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 3E1F9203E5
	for <netdev@vger.kernel.org>; Wed,  6 Jan 2016 18:39:46 -0500 (EST)
In-Reply-To: <1452123571-19140-1-git-send-email-hannes@stressinduktion.org>
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
