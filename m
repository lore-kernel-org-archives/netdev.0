From: =?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
Subject: [PATCH net-next 3/3] vlan: Pass SIOC[SG]HWTSTAMP ioctls to real device
Date: Fri, 27 Jun 2014 11:59:11 +0200
Message-ID: <1403863151-13337-4-git-send-email-stefan.sorensen@spectralink.com>
References: <1403863151-13337-1-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	=?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
To: davem@davemloft.net, richardcochran@gmail.com, kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 213083164162.static.sonofon.dk ([213.83.164.162]:54160 "EHLO
	HORWDSPRD01.spectralink.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752826AbaF0KE6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2014 06:04:58 -0400
In-Reply-To: <1403863151-13337-1-git-send-email-stefan.sorensen@spectralink.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This allows applications to enable hardware timestamping without being =
aware
of it being a vlan device and figuring out the real device.

Signed-off-by: Stefan S=C3=B8rensen <stefan.sorensen@spectralink.com>
---
 net/8021q/vlan_dev.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index ad2ac3c..9d0223b 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -385,6 +385,8 @@ static int vlan_dev_ioctl(struct net_device *dev, s=
truct ifreq *ifr, int cmd)
 	case SIOCGMIIPHY:
 	case SIOCGMIIREG:
 	case SIOCSMIIREG:
+	case SIOCSHWTSTAMP:
+	case SIOCGHWTSTAMP:
 		if (netif_device_present(real_dev) && ops->ndo_do_ioctl)
 			err =3D ops->ndo_do_ioctl(real_dev, &ifrr, cmd);
 		break;
--=20
1.9.3
