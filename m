From: Laurent Navet <laurent.navet@gmail.com>
Subject: [PATCH] drivers: net: can: grcan: use devm_ioremap_resource()
Date: Mon, 13 May 2013 17:27:51 +0200
Message-ID: <1368458871-7402-1-git-send-email-laurent.navet@gmail.com>
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Laurent Navet <laurent.navet@gmail.com>
To: wg@grandegger.com, mkl@pengutronix.de
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replace a call to deprecated devm_request_and_ioremap by devm_ioremap_resource.
dev_err() message is no more needed since it's already displayed in
devm_ioremap_resource().

Signed-off-by: Laurent Navet <laurent.navet@gmail.com>
---
 drivers/net/can/grcan.c |    7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/can/grcan.c b/drivers/net/can/grcan.c
index 17fbc7a..9e9d0d6 100644
--- a/drivers/net/can/grcan.c
+++ b/drivers/net/can/grcan.c
@@ -1683,10 +1683,9 @@ static int grcan_probe(struct platform_device *ofdev)
 	}
 
 	res = platform_get_resource(ofdev, IORESOURCE_MEM, 0);
-	base = devm_request_and_ioremap(&ofdev->dev, res);
-	if (!base) {
-		dev_err(&ofdev->dev, "couldn't map IO resource\n");
-		err = -EADDRNOTAVAIL;
+	base = devm_ioremap_resource(&ofdev->dev, res);
+	if (IS_ERR(base)) {
+		err = PTR_ERR(base);
 		goto exit_error;
 	}
 
-- 
1.7.10.4
