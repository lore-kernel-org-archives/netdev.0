From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net-next 07/10] net: hostap: inherit addr_assign_type along with dev_addr
Date: Fri, 23 Aug 2013 11:35:10 +0200
Message-ID: <1377250513-3662-8-git-send-email-bjorn@mork.no>
References: <1377250513-3662-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, Jouni Malinen <j@w1.fi>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:40757 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754346Ab3HWJf6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Aug 2013 05:35:58 -0400
In-Reply-To: <1377250513-3662-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: Jouni Malinen <j@w1.fi>
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/wireless/hostap/hostap_hw.c   |    2 +-
 drivers/net/wireless/hostap/hostap_main.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/hostap/hostap_hw.c b/drivers/net/wire=
less/hostap/hostap_hw.c
index 6307a4e..c275dc1 100644
--- a/drivers/net/wireless/hostap/hostap_hw.c
+++ b/drivers/net/wireless/hostap/hostap_hw.c
@@ -1425,7 +1425,7 @@ static int prism2_hw_init2(struct net_device *dev=
, int initial)
 		}
 		list_for_each(ptr, &local->hostap_interfaces) {
 			iface =3D list_entry(ptr, struct hostap_interface, list);
-			memcpy(iface->dev->dev_addr, dev->dev_addr, ETH_ALEN);
+			eth_hw_addr_inherit(iface->dev, dev);
 		}
 	} else if (local->fw_ap)
 		prism2_check_sta_fw_version(local);
diff --git a/drivers/net/wireless/hostap/hostap_main.c b/drivers/net/wi=
reless/hostap/hostap_main.c
index e4f56ad..a1257c9 100644
--- a/drivers/net/wireless/hostap/hostap_main.c
+++ b/drivers/net/wireless/hostap/hostap_main.c
@@ -66,7 +66,7 @@ struct net_device * hostap_add_interface(struct local=
_info *local,
 	list_add(&iface->list, &local->hostap_interfaces);
=20
 	mdev =3D local->dev;
-	memcpy(dev->dev_addr, mdev->dev_addr, ETH_ALEN);
+	eth_hw_addr_inherit(dev, mdev);
 	dev->base_addr =3D mdev->base_addr;
 	dev->irq =3D mdev->irq;
 	dev->mem_start =3D mdev->mem_start;
--=20
1.7.10.4
