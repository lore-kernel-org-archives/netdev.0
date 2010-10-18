From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 2/2] drivers/net/ax88796.c: Return error code in failure
Date: Mon, 18 Oct 2010 16:11:14 +0200
Message-ID: <1287411074-19825-2-git-send-email-julia@diku.dk>
Cc: kernel-janitors@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Paul Gortmaker <p_gortmaker@yahoo.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In this code, 0 is returned on failure, even though other
failures return -ENOMEM or other similar values.

A simplified version of the semantic match that finds this problem is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
@a@
identifier alloc;
identifier ret;
constant C;
expression x;
@@

x = alloc(...);
if (x == NULL) { <+... \(ret = -C; \| return -C; \) ...+> }

@@
identifier f, a.alloc;
expression ret;
expression x,e1,e2,e3;
@@

ret = 0
... when != ret = e1
*x = alloc(...)
... when != ret = e2
if (x == NULL) { ... when != ret = e3
  return ret;
}
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
Another call to platform_get_resource in the same function uses -ENXIO, so
I have used the same value here.

 drivers/net/ax88796.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ax88796.c b/drivers/net/ax88796.c
index 20e946b..b6da4cf 100644
--- a/drivers/net/ax88796.c
+++ b/drivers/net/ax88796.c
@@ -864,6 +864,7 @@ static int ax_probe(struct platform_device *pdev)
 	res = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
 	if (res == NULL) {
 		dev_err(&pdev->dev, "no IRQ specified\n");
+		ret = -ENXIO;
 		goto exit_mem;
 	}
 
