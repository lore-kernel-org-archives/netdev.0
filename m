From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net-next 09/10] staging: vt6655: inherit addr_assign_type along with dev_addr
Date: Fri, 23 Aug 2013 11:35:12 +0200
Message-ID: <1377250513-3662-10-git-send-email-bjorn@mork.no>
References: <1377250513-3662-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	devel@driverdev.osuosl.org,
	Forest Bond <forest@alittletooquiet.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:40840 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753724Ab3HWJjl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Aug 2013 05:39:41 -0400
In-Reply-To: <1377250513-3662-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: Forest Bond <forest@alittletooquiet.net>
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/staging/vt6655/hostap.c |    2 +-
 drivers/staging/vt6655/ioctl.c  |    2 +-
 drivers/staging/vt6655/wpactl.c |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/vt6655/hostap.c b/drivers/staging/vt6655/h=
ostap.c
index 57a08c5..8acff44 100644
--- a/drivers/staging/vt6655/hostap.c
+++ b/drivers/staging/vt6655/hostap.c
@@ -86,7 +86,7 @@ static int hostap_enable_hostapd(PSDevice pDevice, in=
t rtnl_locked)
=20
 	apdev_priv =3D netdev_priv(pDevice->apdev);
 	*apdev_priv =3D *pDevice;
-	memcpy(pDevice->apdev->dev_addr, dev->dev_addr, ETH_ALEN);
+	eth_hw_addr_inherit(pDevice->apdev, dev);
=20
 	pDevice->apdev->netdev_ops =3D &apdev_netdev_ops;
=20
diff --git a/drivers/staging/vt6655/ioctl.c b/drivers/staging/vt6655/io=
ctl.c
index 46e0e41..b5cd2e4 100644
--- a/drivers/staging/vt6655/ioctl.c
+++ b/drivers/staging/vt6655/ioctl.c
@@ -460,7 +460,7 @@ int private_ioctl(PSDevice pDevice, struct ifreq *r=
q)
 		}
 		if (sValue.dwValue =3D=3D 1) {
 			DBG_PRT(MSG_LEVEL_DEBUG, KERN_INFO "up wpadev\n");
-			memcpy(pDevice->wpadev->dev_addr, pDevice->dev->dev_addr, ETH_ALEN)=
;
+			eth_hw_addr_inherit(pDevice->wpadev, pDevice->dev);
 			pDevice->bWPADEVUp =3D true;
 		} else {
 			DBG_PRT(MSG_LEVEL_DEBUG, KERN_INFO "close wpadev\n");
diff --git a/drivers/staging/vt6655/wpactl.c b/drivers/staging/vt6655/w=
pactl.c
index 869f62c..e8d9ecd 100644
--- a/drivers/staging/vt6655/wpactl.c
+++ b/drivers/staging/vt6655/wpactl.c
@@ -96,7 +96,7 @@ static int wpa_init_wpadev(PSDevice pDevice)
=20
 	wpadev_priv =3D netdev_priv(pDevice->wpadev);
 	*wpadev_priv =3D *pDevice;
-	memcpy(pDevice->wpadev->dev_addr, dev->dev_addr, ETH_ALEN);
+	eth_hw_addr_inherit(pDevice->wpadev, dev);
 	pDevice->wpadev->base_addr =3D dev->base_addr;
 	pDevice->wpadev->irq =3D dev->irq;
 	pDevice->wpadev->mem_start =3D dev->mem_start;
--=20
1.7.10.4
