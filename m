From: =?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
Subject: [PATCH] net:cpsw: Pass unhandled ioctl's on to generic phy ioctl
Date: Tue,  4 Feb 2014 08:50:42 +0100
Message-ID: <1391500242-10554-1-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
To: mugunthanvnm@ti.com, davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 213083164162.static.sonofon.dk ([213.83.164.162]:38732 "EHLO
	HORWDSPRD01.spectralink.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751234AbaBDHur (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Feb 2014 02:50:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows the use of a generic timestamping phy connected
to the cpsw if CPTS support is not enabled.

Signed-off-by: Stefan S=C3=B8rensen <stefan.sorensen@spectralink.com>
---
 drivers/net/ethernet/ti/cpsw.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/c=
psw.c
index bde63e3..a03cfb3 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1486,12 +1486,12 @@ static int cpsw_ndo_ioctl(struct net_device *de=
v, struct ifreq *req, int cmd)
 #endif
 	case SIOCGMIIPHY:
 		data->phy_id =3D priv->slaves[slave_no].phy->addr;
-		break;
-	default:
-		return -ENOTSUPP;
+		return 0;
 	}
=20
-	return 0;
+	if (!priv->slaves[slave_no].phy)
+		return -EINVAL;
+	return phy_mii_ioctl(priv->slaves[slave_no].phy, req, cmd);
 }
=20
 static void cpsw_ndo_tx_timeout(struct net_device *ndev)
--=20
1.8.5.3
