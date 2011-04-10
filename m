From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH] net: via-velocity: convert to hw_features
Date: Sun, 10 Apr 2011 15:13:21 +0200 (CEST)
Message-ID: <20110410131321.A6EA9138DD@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Francois Romieu <romieu@fr.zoreil.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:58033 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752676Ab1DJNNX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Apr 2011 09:13:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Trivial conversion.

This also enables toggling TX VLAN offload and fixes TX checksumming
race with offload changes.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/via-velocity.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index 0d6fec6..77315ad 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -2600,8 +2600,7 @@ static netdev_tx_t velocity_xmit(struct sk_buff *=
skb,
 	/*
 	 *	Handle hardware checksum
 	 */
-	if ((dev->features & NETIF_F_IP_CSUM) &&
-	    (skb->ip_summed =3D=3D CHECKSUM_PARTIAL)) {
+	if (skb->ip_summed =3D=3D CHECKSUM_PARTIAL) {
 		const struct iphdr *ip =3D ip_hdr(skb);
 		if (ip->protocol =3D=3D IPPROTO_TCP)
 			td_ptr->tdesc1.TCR |=3D TCR0_TCPCK;
@@ -2841,6 +2840,7 @@ static int __devinit velocity_found1(struct pci_d=
ev *pdev, const struct pci_devi
 	dev->ethtool_ops =3D &velocity_ethtool_ops;
 	netif_napi_add(dev, &vptr->napi, velocity_poll, VELOCITY_NAPI_WEIGHT)=
;
=20
+	dev->hw_features =3D NETIF_F_IP_CSUM | NETIF_F_SG | NETIF_F_HW_VLAN_T=
X;
 	dev->features |=3D NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_FILTER |
 		NETIF_F_HW_VLAN_RX | NETIF_F_IP_CSUM;
=20
@@ -3457,13 +3457,10 @@ static const struct ethtool_ops velocity_ethtoo=
l_ops =3D {
 	.get_settings	=3D	velocity_get_settings,
 	.set_settings	=3D	velocity_set_settings,
 	.get_drvinfo	=3D	velocity_get_drvinfo,
-	.set_tx_csum	=3D	ethtool_op_set_tx_csum,
-	.get_tx_csum	=3D	ethtool_op_get_tx_csum,
 	.get_wol	=3D	velocity_ethtool_get_wol,
 	.set_wol	=3D	velocity_ethtool_set_wol,
 	.get_msglevel	=3D	velocity_get_msglevel,
 	.set_msglevel	=3D	velocity_set_msglevel,
-	.set_sg 	=3D	ethtool_op_set_sg,
 	.get_link	=3D	velocity_get_link,
 	.get_coalesce	=3D	velocity_get_coalesce,
 	.set_coalesce	=3D	velocity_set_coalesce,
--=20
1.7.2.5

