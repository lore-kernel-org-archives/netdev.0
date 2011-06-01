From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 4/10] drivers/net/can/flexcan.c: add missing clk_put
Date: Wed,  1 Jun 2011 19:10:07 +0200
Message-ID: <1306948213-20767-4-git-send-email-julia@diku.dk>
Cc: kernel-janitors@vger.kernel.org, socketcan-core@lists.berlios.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia@diku.dk>

The failed_get label is used after the call to clk_get has succeeded, so it
should be moved up above the call to clk_put.

A simplified version of the semantic match that finds this problem is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
@r exists@
expression e1,e2;
statement S;
@@

e1 = clk_get@p1(...);
... when != e1 = e2
    when != clk_put(e1)
    when any
if (...) { ... when != clk_put(e1)
               when != if (...) { ... clk_put(e1) ... }
* return@p3 ...;
 } else S
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 drivers/net/can/flexcan.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
index d499056..121739c 100644
--- a/drivers/net/can/flexcan.c
+++ b/drivers/net/can/flexcan.c
@@ -978,8 +978,8 @@ static int __devinit flexcan_probe(struct platform_device *pdev)
  failed_map:
 	release_mem_region(mem->start, mem_size);
  failed_req:
-	clk_put(clk);
  failed_get:
+	clk_put(clk);
  failed_clock:
 	return err;
 }
