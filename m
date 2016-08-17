From: LABBE Corentin <clabbe.montjoie@gmail.com>
Subject: [PATCH] atm: fore200e: Do not drop const qualifier
Date: Wed, 17 Aug 2016 15:56:45 +0200
Message-ID: <1471442205-11364-1-git-send-email-clabbe.montjoie@gmail.com>
Cc: linux-atm-general@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	LABBE Corentin <clabbe.montjoie@gmail.com>
To: 3chas3@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35747 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750896AbcHQN7X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 09:59:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The data member of structure firmware is const and this constness is
dropped by some cast.
This patch add some const for keeping the const information.

Signed-off-by: LABBE Corentin <clabbe.montjoie@gmail.com>
---
 drivers/atm/fore200e.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/atm/fore200e.c b/drivers/atm/fore200e.c
index 75dde90..81aaa50 100644
--- a/drivers/atm/fore200e.c
+++ b/drivers/atm/fore200e.c
@@ -2489,7 +2489,7 @@ static int fore200e_load_and_start_fw(struct fore200e *fore200e)
 {
     const struct firmware *firmware;
     struct device *device;
-    struct fw_header *fw_header;
+    const struct fw_header *fw_header;
     const __le32 *fw_data;
     u32 fw_size;
     u32 __iomem *load_addr;
@@ -2511,9 +2511,9 @@ static int fore200e_load_and_start_fw(struct fore200e *fore200e)
 	return err;
     }
 
-    fw_data = (__le32 *) firmware->data;
+    fw_data = (const __le32 *)firmware->data;
     fw_size = firmware->size / sizeof(u32);
-    fw_header = (struct fw_header *) firmware->data;
+    fw_header = (const struct fw_header *)firmware->data;
     load_addr = fore200e->virt_base + le32_to_cpu(fw_header->load_offset);
 
     DPRINTK(2, "device %s firmware being loaded at 0x%p (%d words)\n",
-- 
2.7.3
