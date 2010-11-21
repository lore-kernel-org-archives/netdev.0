From: Joe Perches <joe@perches.com>
Subject: [PATCH 36/62] qlge: Use static const
Date: Sat, 20 Nov 2010 18:38:37 -0800
Message-ID: <48665ee85cb773b28d8389077cac9a7467440443.1290305776.git.joe@perches.com>
References: <cover.1290305773.git.joe@perches.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Ron Mercer <ron.mercer@qlogic.com>, linux-driver@qlogic.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1290305773.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Using static const generally increases object text and decreases data size.
It also generally decreases overall object size.

   text	   data	    bss	    dec	    hex	filename
  66820	    265	  15296	  82381	  141cd	drivers/net/qlge/qlge_main.o.old
  66786	    265	  15296	  82347	  141ab	drivers/net/qlge/qlge_main.o.new

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/qlge/qlge_main.c |   13 +++++++------
 1 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index d9a7626..01b0533 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -3548,12 +3548,13 @@ err_irq:
 
 static int ql_start_rss(struct ql_adapter *qdev)
 {
-	u8 init_hash_seed[] = {0x6d, 0x5a, 0x56, 0xda, 0x25, 0x5b, 0x0e, 0xc2,
-				0x41, 0x67, 0x25, 0x3d, 0x43, 0xa3, 0x8f,
-				0xb0, 0xd0, 0xca, 0x2b, 0xcb, 0xae, 0x7b,
-				0x30, 0xb4, 0x77, 0xcb, 0x2d, 0xa3, 0x80,
-				0x30, 0xf2, 0x0c, 0x6a, 0x42, 0xb7, 0x3b,
-				0xbe, 0xac, 0x01, 0xfa};
+	static const u8 init_hash_seed[] = {
+		0x6d, 0x5a, 0x56, 0xda, 0x25, 0x5b, 0x0e, 0xc2,
+		0x41, 0x67, 0x25, 0x3d, 0x43, 0xa3, 0x8f, 0xb0,
+		0xd0, 0xca, 0x2b, 0xcb, 0xae, 0x7b, 0x30, 0xb4,
+		0x77, 0xcb, 0x2d, 0xa3, 0x80, 0x30, 0xf2, 0x0c,
+		0x6a, 0x42, 0xb7, 0x3b, 0xbe, 0xac, 0x01, 0xfa
+	};
 	struct ricb *ricb = &qdev->ricb;
 	int status = 0;
 	int i;
-- 
1.7.3.2.245.g03276.dirty
