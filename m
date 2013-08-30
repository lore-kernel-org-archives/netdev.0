From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH v2 net-next 4/9] net: macvlan: inherit addr_assign_type along with dev_addr
Date: Fri, 30 Aug 2013 18:08:47 +0200
Message-ID: <1377878932-26881-5-git-send-email-bjorn@mork.no>
References: <1377878932-26881-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>,
	Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:55487 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756875Ab3H3QKQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Aug 2013 12:10:16 -0400
In-Reply-To: <1377878932-26881-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A device inheriting a random or set address should reflect this in
its addr_assign_type.

Cc: Patrick McHardy <kaber@trash.net>
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/macvlan.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 510a9b6..3bc9761 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -823,7 +823,7 @@ int macvlan_common_newlink(struct net *src_net, str=
uct net_device *dev,
 		if (port->count)
 			return -EINVAL;
 		port->passthru =3D true;
-		memcpy(dev->dev_addr, lowerdev->dev_addr, ETH_ALEN);
+		eth_hw_addr_inherit(dev, lowerdev);
 	}
=20
 	err =3D netdev_upper_dev_link(lowerdev, dev);
--=20
1.7.10.4
