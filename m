From: Bastian Blank <waldi@debian.org>
Subject: [PATCH] bnx2 - Don't use reserved names
Date: Wed, 8 Apr 2009 23:16:56 +0200
Message-ID: <20090408211656.GA21010@wavehammer.waldi.eu.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: davem@davemloft.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wavehammer.waldi.eu.org ([82.139.201.20]:44893 "EHLO
	wavehammer.waldi.eu.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755498AbZDHVRA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2009 17:17:00 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mips identifier is reserved by gcc on mips plattforms. Don't use it
in the code.

Signed-off-by: Bastian Blank <waldi@debian.org>
---
 drivers/net/bnx2.c |   26 +++++++++++++-------------
 1 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 9d268be..d478391 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -3427,8 +3427,8 @@ static int __devinit
 bnx2_request_firmware(struct bnx2 *bp)
 {
 	const char *mips_fw_file, *rv2p_fw_file;
-	const struct bnx2_mips_fw_file *mips;
-	const struct bnx2_rv2p_fw_file *rv2p;
+	const struct bnx2_mips_fw_file *mips_fw;
+	const struct bnx2_rv2p_fw_file *rv2p_fw;
 	int rc;
 
 	if (CHIP_NUM(bp) == CHIP_NUM_5709) {
@@ -3452,21 +3452,21 @@ bnx2_request_firmware(struct bnx2 *bp)
 		       rv2p_fw_file);
 		return rc;
 	}
-	mips = (const struct bnx2_mips_fw_file *) bp->mips_firmware->data;
-	rv2p = (const struct bnx2_rv2p_fw_file *) bp->rv2p_firmware->data;
-	if (bp->mips_firmware->size < sizeof(*mips) ||
-	    check_mips_fw_entry(bp->mips_firmware, &mips->com) ||
-	    check_mips_fw_entry(bp->mips_firmware, &mips->cp) ||
-	    check_mips_fw_entry(bp->mips_firmware, &mips->rxp) ||
-	    check_mips_fw_entry(bp->mips_firmware, &mips->tpat) ||
-	    check_mips_fw_entry(bp->mips_firmware, &mips->txp)) {
+	mips_fw = (const struct bnx2_mips_fw_file *) bp->mips_firmware->data;
+	rv2p_fw = (const struct bnx2_rv2p_fw_file *) bp->rv2p_firmware->data;
+	if (bp->mips_firmware->size < sizeof(*mips_fw) ||
+	    check_mips_fw_entry(bp->mips_firmware, &mips_fw->com) ||
+	    check_mips_fw_entry(bp->mips_firmware, &mips_fw->cp) ||
+	    check_mips_fw_entry(bp->mips_firmware, &mips_fw->rxp) ||
+	    check_mips_fw_entry(bp->mips_firmware, &mips_fw->tpat) ||
+	    check_mips_fw_entry(bp->mips_firmware, &mips_fw->txp)) {
 		printk(KERN_ERR PFX "Firmware file \"%s\" is invalid\n",
 		       mips_fw_file);
 		return -EINVAL;
 	}
-	if (bp->rv2p_firmware->size < sizeof(*rv2p) ||
-	    check_fw_section(bp->rv2p_firmware, &rv2p->proc1.rv2p, 8, true) ||
-	    check_fw_section(bp->rv2p_firmware, &rv2p->proc2.rv2p, 8, true)) {
+	if (bp->rv2p_firmware->size < sizeof(*rv2p_fw) ||
+	    check_fw_section(bp->rv2p_firmware, &rv2p_fw->proc1.rv2p, 8, true) ||
+	    check_fw_section(bp->rv2p_firmware, &rv2p_fw->proc2.rv2p, 8, true)) {
 		printk(KERN_ERR PFX "Firmware file \"%s\" is invalid\n",
 		       rv2p_fw_file);
 		return -EINVAL;
-- 
1.6.2.2
