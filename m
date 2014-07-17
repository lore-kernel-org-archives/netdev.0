From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 12/14] be2net: avoid SRIOV config for BE2 chip
Date: Thu, 17 Jul 2014 16:20:30 +0530
Message-ID: <1405594232-30818-13-git-send-email-sathya.perla@emulex.com>
References: <1405594232-30818-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:22738 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756818AbaGQKso (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 06:48:44 -0400
In-Reply-To: <1405594232-30818-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasundhara Volam <vasundhara.volam@emulex.com>

As SRIOV is not supported on BE2 chip, avoid calling be_get/set_sriov_config()
for BE2 chip.

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index c622e42..427e0d7 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3434,7 +3434,9 @@ static int be_get_config(struct be_adapter *adapter)
 		if (!status)
 			dev_info(&adapter->pdev->dev,
 				 "Using profile 0x%x\n", profile_id);
+	}
 
+	if (!BE2_chip(adapter) && be_physfn(adapter)) {
 		status = be_get_sriov_config(adapter);
 		if (status)
 			return status;
-- 
1.7.1
