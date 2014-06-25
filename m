From: =?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
Subject: [PATCH net-next 2/2] vlan: Pass SIOC[SG]HWTSTAMP ioctls to real device
Date: Wed, 25 Jun 2014 14:25:48 +0200
Message-ID: <1403699148-10640-3-git-send-email-stefan.sorensen@spectralink.com>
References: <1403699148-10640-1-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	=?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
To: davem@davemloft.net, richardcochran@gmail.com, kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cicero-fbr1.cybercity.dk ([212.242.40.5]:35649 "EHLO
	cicero4.cybercity.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752337AbaFYNG7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 09:06:59 -0400
Received: from cicero2.cybercity.dk (cicero2.cybercity.dk [212.242.40.53])
	by cicero4.cybercity.dk (Postfix) with ESMTP id 491A1DB5BD
	for <netdev@vger.kernel.org>; Wed, 25 Jun 2014 14:28:39 +0200 (CEST)
Received: from HORWDSPRD01.spectralink.com (213083164185.static.sonofon.dk [213.83.164.185])
	by cicero2.cybercity.dk (Postfix) with ESMTP id 396CB108893
	for <netdev@vger.kernel.org>; Wed, 25 Jun 2014 14:27:48 +0200 (CEST)
In-Reply-To: <1403699148-10640-1-git-send-email-stefan.sorensen@spectralink.com>
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
