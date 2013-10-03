From: Somnath Kotur <somnath.kotur@emulex.com>
Subject: [PATCH net] be2net: Warn users of possible broken functionality on BE2 cards with very old F/W versions with latest driver.
Date: Thu, 3 Oct 2013 12:33:46 +0530
Message-ID: <e84f68dc-6ab3-4e56-b2f5-70e51c46d1c3@CMEXHTCAS1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Somnath Kotur <somnath.kotur@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:8930 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752920Ab3JCHFG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Oct 2013 03:05:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On very old F/W versions < 4.0, the mailbox command to set interrupts on the
card succeeds even though it is not supported and should have failed leading to
interrupts not working.
Hence warn users to upgrade to a suitable F/W version to avoid seeing broken
functionality.

Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 2c38cc4..f4bbc92 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3247,6 +3247,11 @@ static int be_setup(struct be_adapter *adapter)
 
 	be_cmd_get_fw_ver(adapter, adapter->fw_ver, adapter->fw_on_flash);
 
+	if (BE2_chip(adapter) && memcmp(adapter->fw_ver, "4.", 2) < 0) {
+		dev_err(dev, "F/W version is very old. IRQs may not work\n");
+		dev_err(dev, "Pls upgrade to F/W version >= 4.0\n");
+	}
+
 	if (adapter->vlans_added)
 		be_vid_config(adapter);
 
-- 
1.6.0.2
