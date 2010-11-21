From: Joe Perches <joe@perches.com>
Subject: [PATCH 29/62] jme: Use static const
Date: Sat, 20 Nov 2010 18:38:30 -0800
Message-ID: <fce48d2d72040da35a2b4c4fa29f3376e70b93ff.1290305776.git.joe@perches.com>
References: <cover.1290305773.git.joe@perches.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Guo-Fu Tseng <cooldavid@cooldavid.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1290305773.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Using static const generally increases object text and decreases data size.
It also generally decreases overall object size.

   text	   data	    bss	    dec	    hex	filename
  38255	    248	  10408	  48911	   bf0f	drivers/net/jme.o.new
  38252	    248	  10408	  48908	   bf0c	drivers/net/jme.o.old

Change jme_setup_wakeup_frame to take a const *.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/jme.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/jme.c b/drivers/net/jme.c
index c57d9a4..d6289fb 100644
--- a/drivers/net/jme.c
+++ b/drivers/net/jme.c
@@ -135,7 +135,7 @@ jme_reset_phy_processor(struct jme_adapter *jme)
 
 static void
 jme_setup_wakeup_frame(struct jme_adapter *jme,
-		u32 *mask, u32 crc, int fnr)
+		       const u32 *mask, u32 crc, int fnr)
 {
 	int i;
 
@@ -163,7 +163,7 @@ jme_setup_wakeup_frame(struct jme_adapter *jme,
 static inline void
 jme_reset_mac_processor(struct jme_adapter *jme)
 {
-	u32 mask[WAKEUP_FRAME_MASK_DWNR] = {0, 0, 0, 0};
+	static const u32 mask[WAKEUP_FRAME_MASK_DWNR] = {0, 0, 0, 0};
 	u32 crc = 0xCDCDCDCD;
 	u32 gpreg0;
 	int i;
-- 
1.7.3.2.245.g03276.dirty
