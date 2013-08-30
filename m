From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH v2 net-next 2/9] net: vlan: inherit addr_assign_type along with dev_addr
Date: Fri, 30 Aug 2013 18:08:45 +0200
Message-ID: <1377878932-26881-3-git-send-email-bjorn@mork.no>
References: <1377878932-26881-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>,
	Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:55486 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756878Ab3H3QKQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Aug 2013 12:10:16 -0400
In-Reply-To: <1377878932-26881-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A device inheriting a random or set address should reflect this in
its addr_assign_type.

Cc: Patrick McHardy <kaber@trash.net>
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 net/8021q/vlan_dev.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 9ab8a7e..09bf1c3 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -582,7 +582,7 @@ static int vlan_dev_init(struct net_device *dev)
 	dev->dev_id =3D real_dev->dev_id;
=20
 	if (is_zero_ether_addr(dev->dev_addr))
-		memcpy(dev->dev_addr, real_dev->dev_addr, dev->addr_len);
+		eth_hw_addr_inherit(dev, real_dev);
 	if (is_zero_ether_addr(dev->broadcast))
 		memcpy(dev->broadcast, real_dev->broadcast, dev->addr_len);
=20
--=20
1.7.10.4
