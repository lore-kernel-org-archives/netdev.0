From: Somnath Kotur <somnath.kotur@emulex.com>
Subject: [PATCH net v2] be2net: Warn users of possible broken functionality on BE2 cards with very old FW versions with latest driver
Date: Thu, 3 Oct 2013 15:34:29 +0530
Message-ID: <cca19523-3f51-4f87-b0e1-2ecec6ba37d4@CMEXHTCAS1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Somnath Kotur <somnath.kotur@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:18035 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751740Ab3JCKFt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Oct 2013 06:05:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On very old FW versions < 4.0, the mailbox command to set interrupts
on the card succeeds even though it is not supported and should have
failed, leading to a scenario where interrupts do not work.
Hence warn users to upgrade to a suitable FW version to avoid seeing
broken functionality.

Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
---
v2: Replaced all occurences of 'F/W' with 'FW' or 'Firmware' as suggested by
Sathya

 drivers/net/ethernet/emulex/benet/be_main.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 2c38cc4..9563ced 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3247,6 +3247,11 @@ static int be_setup(struct be_adapter *adapter)
 
 	be_cmd_get_fw_ver(adapter, adapter->fw_ver, adapter->fw_on_flash);
 
+	if (BE2_chip(adapter) && memcmp(adapter->fw_ver, "4.", 2) < 0) {
+		dev_err(dev, "Firmware version is too old.IRQs may not work\n");
+		dev_err(dev, "Pls upgrade firmware to version >= 4.0\n");
+	}
+
 	if (adapter->vlans_added)
 		be_vid_config(adapter);
 
-- 
1.6.0.2
