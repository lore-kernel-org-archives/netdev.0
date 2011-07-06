From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: [PATCH bug-fix v2] net: vlan: enable soft features regardless of
 underlying device
Date: Wed, 06 Jul 2011 10:08:44 +0800
Message-ID: <4E13C3AC.3050407@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: David Miller <davem@davemloft.net>,
	=?UTF-8?B?5Y2V5Y2r?= <shanwei@cn.fujitsu.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:62728 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752691Ab1GFCHf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 22:07:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If gso/gro feature of underlying device is turned off=EF=BC=8C
then new created vlan device never can turn gso/gro on.=20

Although underlying device don't support TSO, we still
should use software segments for vlan device.

Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
---
v2: only update changelog and title.
---
 net/8021q/vlan_dev.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 1c9aa8c..d8f45ba 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -588,9 +588,14 @@ static void vlan_dev_uninit(struct net_device *dev=
)
 static u32 vlan_dev_fix_features(struct net_device *dev, u32 features)
 {
 	struct net_device *real_dev =3D vlan_dev_info(dev)->real_dev;
+	u32 old_features =3D features;
=20
 	features &=3D real_dev->features;
 	features &=3D real_dev->vlan_features;
+
+	if (old_features & NETIF_F_SOFT_FEATURES)
+		features |=3D old_features & NETIF_F_SOFT_FEATURES;
+
 	if (dev_ethtool_get_rx_csum(real_dev))
 		features |=3D NETIF_F_RXCSUM;
 	features |=3D NETIF_F_LLTX;
--=20
1.7.4.1
