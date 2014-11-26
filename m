From: Smart Weblications GmbH - Florian Wiessner
	<f.wiessner@smart-weblications.de>
Subject: [PATCH] add an empty ndo_poll_controller to veth to make bridges
 happy to support poll with veth devices attached
Date: Wed, 26 Nov 2014 23:32:06 +0100
Message-ID: <547654E6.8040005@smart-weblications.de>
Reply-To: f.wiessner@smart-weblications.de
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.smart-weblications.de ([188.65.144.61]:58231 "EHLO
	mail.smart-weblications.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750804AbaKZWcS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2014 17:32:18 -0500
Received: from office.smart-weblications.net (office.smart-weblications.net [91.204.168.193])
	by mail.smart-weblications.de (Postfix) with ESMTPA id 8CF1F4430E9
	for <netdev@vger.kernel.org>; Wed, 26 Nov 2014 22:32:16 +0000 (UTC)
Received: from [192.168.200.60] (unknown [192.168.200.60])
	by office.smart-weblications.net (Postfix) with ESMTPA id DF9CFC0D47
	for <netdev@vger.kernel.org>; Wed, 26 Nov 2014 23:32:15 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi netdev,


what do i need to do to get these patches to 3.10, 3.12, 3.14 lts?

for kernels 3.10, 3.12:


This patch adds netpoll "support" to veth. As veth is a virtual device =
there is
no need to support netpoll. We just need
to tell the kernel veth supports it to have netpoll support on bridging=
 while
veth devices are assigned.
An example is the netconsole driver on a bridge.

Signed-off-by: Stefan Priebe <s.priebe@profihost.ag>
---
  drivers/net/veth.c | 9 +++++++++
  1 file changed, 9 insertions(+)
--- veth.c-orig 2014-11-26 23:30:26.104210917 +0100
+++ veth.c      2014-11-26 23:29:37.357444217 +0100
@@ -188,6 +188,12 @@
        return tot;
 }

+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void veth_poll_controller(struct net_device *dev)
+{
+}
+#endif
+
 static int veth_open(struct net_device *dev)
 {
        struct veth_priv *priv =3D netdev_priv(dev);
@@ -251,6 +257,9 @@
        .ndo_change_mtu      =3D veth_change_mtu,
        .ndo_get_stats64     =3D veth_get_stats64,
        .ndo_set_mac_address =3D eth_mac_addr,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+       .ndo_poll_controller =3D veth_poll_controller,
+#endif
 };

 #define VETH_FEATURES (NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_ALL_TSO=
 |    \



for kernels 3.14.25, 3.16.7:


This patch adds netpoll "support" to veth. As veth is a virtual device =
there is
no need to support netpoll. We just need
to tell the kernel veth supports it to have netpoll support on bridging=
 while
veth devices are assigned.
An example is the netconsole driver on a bridge.

Signed-off-by: Florian Wiessner <f.wiessner@smart-kvm.com>

--- veth.c.orig 2014-11-26 23:22:57.926041383 +0100
+++ veth.c      2014-11-26 23:23:42.584757995 +0100
@@ -188,6 +188,12 @@
        return tot;
 }

+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void veth_poll_controller(struct net_device *dev)
+{
+}
+#endif
+
 /* fake multicast ability */
 static void veth_set_multicast_list(struct net_device *dev)
 {
@@ -265,6 +271,9 @@
        .ndo_get_stats64     =3D veth_get_stats64,
        .ndo_set_rx_mode     =3D veth_set_multicast_list,
        .ndo_set_mac_address =3D eth_mac_addr,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+        .ndo_poll_controller    =3D veth_poll_controller,
+#endif
 };

 #define VETH_FEATURES (NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_ALL_TSO=
 |    \


--=20

Mit freundlichen Gr=FC=DFen,

=46lorian Wiessner

Smart Weblications GmbH
Martinsberger Str. 1
D-95119 Naila

fon.: +49 9282 9638 200
fax.: +49 9282 9638 205
24/7: +49 900 144 000 00 - 0,99 EUR/Min*
http://www.smart-weblications.de

--
Sitz der Gesellschaft: Naila
Gesch=E4ftsf=FChrer: Florian Wiessner
HRB-Nr.: HRB 3840 Amtsgericht Hof
*aus dem dt. Festnetz, ggf. abweichende Preise aus dem Mobilfunknetz
