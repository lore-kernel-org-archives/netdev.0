From: fgao@ikuai8.com
Subject: [PATCH net-next 1/1] driver: macvlan: Replace integer number with bool value
Date: Mon, 14 Nov 2016 08:24:19 +0800
Message-ID: <1479083059-12688-1-git-send-email-fgao@ikuai8.com>
To: davem@davemloft.net, kaber@trash.net, netdev@vger.kernel.org,
        gfree.wind@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from SMTPBG352.QQ.COM ([183.57.50.167]:55832 "EHLO smtpbg352.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751418AbcKNAZI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 13 Nov 2016 19:25:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <gfree.wind@gmail.com>

The return value of function macvlan_addr_busy is used as bool value,
so use bool value instead of integer number "1" and "0".

Signed-off-by: Gao Feng <gfree.wind@gmail.com>
---
 drivers/net/macvlan.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index a064415..d0361f3 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -179,20 +179,20 @@ static void macvlan_hash_change_addr(struct macvlan_dev *vlan,
 	macvlan_hash_add(vlan);
 }
 
-static int macvlan_addr_busy(const struct macvlan_port *port,
-				const unsigned char *addr)
+static bool macvlan_addr_busy(const struct macvlan_port *port,
+			      const unsigned char *addr)
 {
 	/* Test to see if the specified multicast address is
 	 * currently in use by the underlying device or
 	 * another macvlan.
 	 */
 	if (ether_addr_equal_64bits(port->dev->dev_addr, addr))
-		return 1;
+		return true;
 
 	if (macvlan_hash_lookup(port, addr))
-		return 1;
+		return true;
 
-	return 0;
+	return false;
 }
 
 
-- 
1.9.1
