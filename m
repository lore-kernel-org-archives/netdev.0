From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH] net: vlan: inherit addr_assign_type along with dev_addr
Date: Thu, 22 Aug 2013 14:23:21 +0200
Message-ID: <1377174201-20236-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:52789 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752075Ab3HVMXb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Aug 2013 08:23:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A vlan device inheriting a random or set address should reflect
this in its addr_assign_type.

Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 net/8021q/vlan_dev.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 1cd3d2a..995684d 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -581,8 +581,10 @@ static int vlan_dev_init(struct net_device *dev)
 	/* ipv6 shared card related stuff */
 	dev->dev_id =3D real_dev->dev_id;
=20
-	if (is_zero_ether_addr(dev->dev_addr))
+	if (is_zero_ether_addr(dev->dev_addr)) {
 		memcpy(dev->dev_addr, real_dev->dev_addr, dev->addr_len);
+		dev->addr_assign_type =3D real_dev->addr_assign_type;
+	}
 	if (is_zero_ether_addr(dev->broadcast))
 		memcpy(dev->broadcast, real_dev->broadcast, dev->addr_len);
=20
--=20
1.7.10.4
