From: Jon Mason <jon.mason@exar.com>
Subject: [PATCH 4/4] Using static const generally increases object text and decreases data size. It also generally decreases overall object size.
Date: Fri, 10 Dec 2010 19:40:04 -0600
Message-ID: <1292031604-16628-4-git-send-email-jon.mason@exar.com>
References: <1292031604-16628-1-git-send-email-jon.mason@exar.com>
Cc: netdev@vger.kernel.org,
	Sivakumar Subramani <sivakumar.subramani@exar.com>,
	Sreenivasa Honnur <sreenivasa.honnur@exar.com>,
	Ram Vepa <ram.vepa@exar.com>, Joe Perches <joe@perches.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:36500 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751942Ab0LKBk2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 20:40:28 -0500
Received: by ywl5 with SMTP id 5so2426131ywl.19
        for <netdev@vger.kernel.org>; Fri, 10 Dec 2010 17:40:28 -0800 (PST)
In-Reply-To: <1292031604-16628-1-git-send-email-jon.mason@exar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

   text	   data	    bss	    dec	    hex	filename
 109387	    389	  24432	 134208	  20c40	drivers/net/s2io.o.old
 109358	    389	  24432	 134179	  20c23	drivers/net/s2io.o.new

Signed-off-by: Joe Perches <joe@perches.com>
Acked-by: Jon Mason <jon.mason@exar.com>
---
 drivers/net/s2io.c |   20 ++++++++++++--------
 1 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 80efc05..9a1e32f 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -3598,10 +3598,12 @@ static int s2io_set_swapper(struct s2io_nic *sp)
 	val64 = readq(&bar0->pif_rd_swapper_fb);
 	if (val64 != 0x0123456789ABCDEFULL) {
 		int i = 0;
-		u64 value[] = { 0xC30000C3C30000C3ULL,   /* FE=1, SE=1 */
-				0x8100008181000081ULL,  /* FE=1, SE=0 */
-				0x4200004242000042ULL,  /* FE=0, SE=1 */
-				0};                     /* FE=0, SE=0 */
+		static const u64 value[] = {
+			0xC30000C3C30000C3ULL,	/* FE=1, SE=1 */
+			0x8100008181000081ULL,	/* FE=1, SE=0 */
+			0x4200004242000042ULL,	/* FE=0, SE=1 */
+			0			/* FE=0, SE=0 */
+		};
 
 		while (i < 4) {
 			writeq(value[i], &bar0->swapper_ctrl);
@@ -3627,10 +3629,12 @@ static int s2io_set_swapper(struct s2io_nic *sp)
 
 	if (val64 != valt) {
 		int i = 0;
-		u64 value[] = { 0x00C3C30000C3C300ULL,  /* FE=1, SE=1 */
-				0x0081810000818100ULL,  /* FE=1, SE=0 */
-				0x0042420000424200ULL,  /* FE=0, SE=1 */
-				0};                     /* FE=0, SE=0 */
+		static const u64 value[] = {
+			0x00C3C30000C3C300ULL,	/* FE=1, SE=1 */
+			0x0081810000818100ULL,	/* FE=1, SE=0 */
+			0x0042420000424200ULL,	/* FE=0, SE=1 */
+			0			/* FE=0, SE=0 */
+		};
 
 		while (i < 4) {
 			writeq((value[i] | valr), &bar0->swapper_ctrl);
-- 
1.7.0.4

