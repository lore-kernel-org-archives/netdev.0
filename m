From: Joe Perches <joe@perches.com>
Subject: [PATCH 44/62] tulip: Use static const
Date: Sat, 20 Nov 2010 18:38:45 -0800
Message-ID: <a03b7c847d0b46bcf25ac759b3947d50509f8cea.1290305776.git.joe@perches.com>
References: <cover.1290305773.git.joe@perches.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Grant Grundler <grundler@parisc-linux.org>,
	Kyle McMartin <kyle@mcmartin.ca>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1290305773.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Using static const generally increases object text and decreases data size.
It also generally decreases overall object size.

   text	   data	    bss	    dec	    hex	filename
  26607	    288	   5960	  32855	   8057	drivers/net/tulip/de2104x.o.old
  26587	    288	   5960	  32835	   8043	drivers/net/tulip/de2104x.o.new

Changed de_next_media to take a const u32 *.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/tulip/de2104x.c |   18 ++++++++++++------
 1 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/drivers/net/tulip/de2104x.c b/drivers/net/tulip/de2104x.c
index c78a505..b13c6b0 100644
--- a/drivers/net/tulip/de2104x.c
+++ b/drivers/net/tulip/de2104x.c
@@ -964,7 +964,7 @@ static void de_set_media (struct de_private *de)
 		dw32(MacMode, macmode);
 }
 
-static void de_next_media (struct de_private *de, u32 *media,
+static void de_next_media (struct de_private *de, const u32 *media,
 			   unsigned int n_media)
 {
 	unsigned int i;
@@ -1008,10 +1008,10 @@ static void de21040_media_timer (unsigned long data)
 		return;
 
 	if (de->media_type == DE_MEDIA_AUI) {
-		u32 next_state = DE_MEDIA_TP;
+		static const u32 next_state = DE_MEDIA_TP;
 		de_next_media(de, &next_state, 1);
 	} else {
-		u32 next_state = DE_MEDIA_AUI;
+		static const u32 next_state = DE_MEDIA_AUI;
 		de_next_media(de, &next_state, 1);
 	}
 
@@ -1136,13 +1136,19 @@ static void de21041_media_timer (unsigned long data)
 	 * simply resets the PHY and reloads the current media settings.
 	 */
 	if (de->media_type == DE_MEDIA_AUI) {
-		u32 next_states[] = { DE_MEDIA_BNC, DE_MEDIA_TP_AUTO };
+		static const u32 next_states[] = {
+			DE_MEDIA_BNC, DE_MEDIA_TP_AUTO
+		};
 		de_next_media(de, next_states, ARRAY_SIZE(next_states));
 	} else if (de->media_type == DE_MEDIA_BNC) {
-		u32 next_states[] = { DE_MEDIA_TP_AUTO, DE_MEDIA_AUI };
+		static const u32 next_states[] = {
+			DE_MEDIA_TP_AUTO, DE_MEDIA_AUI
+		};
 		de_next_media(de, next_states, ARRAY_SIZE(next_states));
 	} else {
-		u32 next_states[] = { DE_MEDIA_AUI, DE_MEDIA_BNC, DE_MEDIA_TP_AUTO };
+		static const u32 next_states[] = {
+			DE_MEDIA_AUI, DE_MEDIA_BNC, DE_MEDIA_TP_AUTO
+		};
 		de_next_media(de, next_states, ARRAY_SIZE(next_states));
 	}
 
-- 
1.7.3.2.245.g03276.dirty
