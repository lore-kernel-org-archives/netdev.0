From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH net-next] net: greth: Utilize of_get_mac_address()
Date: Tue, 21 Mar 2017 11:24:38 +0100
Message-ID: <20170321102438.31382-1-tklauser@distanz.ch>
Cc: netdev@vger.kernel.org
To: Andreas Larsson <andreas@gaisler.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:59242 "EHLO mail.zhinst.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756440AbdCUKYn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 21 Mar 2017 06:24:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do not open code getting the MAC address exclusively from the
"local-mac-address" property, but instead use of_get_mac_address() which
looks up the MAC address using the 3 typical property names.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/ethernet/aeroflex/greth.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/aeroflex/greth.c b/drivers/net/ethernet/aeroflex/greth.c
index 9f7422ada704..d8e133ced7b8 100644
--- a/drivers/net/ethernet/aeroflex/greth.c
+++ b/drivers/net/ethernet/aeroflex/greth.c
@@ -34,6 +34,7 @@
 #include <linux/crc32.h>
 #include <linux/mii.h>
 #include <linux/of_device.h>
+#include <linux/of_net.h>
 #include <linux/of_platform.h>
 #include <linux/slab.h>
 #include <asm/cacheflush.h>
@@ -1454,11 +1455,10 @@ static int greth_of_probe(struct platform_device *ofdev)
 			break;
 	}
 	if (i == 6) {
-		const unsigned char *addr;
-		int len;
-		addr = of_get_property(ofdev->dev.of_node, "local-mac-address",
-					&len);
-		if (addr != NULL && len == 6) {
+		const u8 *addr;
+
+		addr = of_get_mac_address(ofdev->dev.of_node);
+		if (addr) {
 			for (i = 0; i < 6; i++)
 				macaddr[i] = (unsigned int) addr[i];
 		} else {
-- 
2.11.0
