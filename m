From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: [PATCH] net: typhoon: Remove redundant casts
Date: Tue, 21 Oct 2014 16:51:43 +0200
Message-ID: <1413903103-3047-1-git-send-email-linux@rasmusvillemoes.dk>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Rasmus Villemoes <linux@rasmusvillemoes.dk>
To: David Dillow <dave@thedillows.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Both image_data and typhoon_fw->data are const u8*, so the cast to u8*
is unnecessary and confusing.

Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
---
 drivers/net/ethernet/3com/typhoon.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/3com/typhoon.c b/drivers/net/ethernet/3com/typhoon.c
index 48775b8..dede43f 100644
--- a/drivers/net/ethernet/3com/typhoon.c
+++ b/drivers/net/ethernet/3com/typhoon.c
@@ -1285,7 +1285,7 @@ typhoon_request_firmware(struct typhoon *tp)
 		return err;
 	}
 
-	image_data = (u8 *) typhoon_fw->data;
+	image_data = typhoon_fw->data;
 	remaining = typhoon_fw->size;
 	if (remaining < sizeof(struct typhoon_file_header))
 		goto invalid_fw;
@@ -1343,7 +1343,7 @@ typhoon_download_firmware(struct typhoon *tp)
 	int i;
 	int err;
 
-	image_data = (u8 *) typhoon_fw->data;
+	image_data = typhoon_fw->data;
 	fHdr = (struct typhoon_file_header *) image_data;
 
 	/* Cannot just map the firmware image using pci_map_single() as
-- 
2.0.4
