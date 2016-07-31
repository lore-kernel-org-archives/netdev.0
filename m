From: Heinrich Schuchardt <xypron.glpk@gmx.de>
Subject: [PATCH 1/1] net: caif: use correct format specifier
Date: Sun, 31 Jul 2016 09:19:50 +0200
Message-ID: <1469949590-19166-1-git-send-email-xypron.glpk@gmx.de>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Heinrich Schuchardt <xypron.glpk@gmx.de>
To: Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

%u is the wrong format specifier for int.
size_t cannot be converted to int without possible
loss of information.

So leave the result as size_t and use %zu as format specifier.

cf. Documentation/printk-formats.txt

Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>
---
 drivers/net/caif/caif_spi.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/caif/caif_spi.c b/drivers/net/caif/caif_spi.c
index 4721948..3a529fb 100644
--- a/drivers/net/caif/caif_spi.c
+++ b/drivers/net/caif/caif_spi.c
@@ -185,8 +185,8 @@ static ssize_t print_frame(char *buf, size_t size, char *frm,
 			/* Fast forward. */
 			i = count - cut;
 			len += snprintf((buf + len), (size - len),
-					"--- %u bytes skipped ---\n",
-					(int)(count - (cut * 2)));
+					"--- %zu bytes skipped ---\n",
+					count - (cut * 2));
 		}
 
 		if ((!(i % 10)) && i) {
-- 
2.8.1
