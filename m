From: Nishit Shah <nsshah.82@gmail.com>
Subject: [PATCH] r8168: r8168 fixes
Date: Wed, 3 Jun 2009 14:14:11 +0530
Message-ID: <b2d58cb80906030144m6cb7c848se1fe5f471b4688ed@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f112.google.com ([209.85.221.112]:33881 "EHLO
	mail-qy0-f112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751713AbZFCIoL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2009 04:44:11 -0400
Received: by qyk10 with SMTP id 10so59256qyk.33
        for <netdev@vger.kernel.org>; Wed, 03 Jun 2009 01:44:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

The following patch fixes three r8168 bugs:

1) vlan tag missing in transmit path. Due to incorrect assignment of
transmit vlan tag option, driver is not able to transmit data on vlan
interface.

2) compilation warning with rtl8168_powerup_pll if CONFIG_PM isn=92t de=
fined.

3) compilation warning with unused variable dev in rtl8168_tx_clear.

Signed-off-by: Rajesh Modhwadiya <rajesh.modhwadiya@elitecore.com>
Signed-off-by: Nishit Shah <nishit.shah@elitecore.com>

---
r8168_n.c |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

--- r8168-8.011.00/src/r8168_n.c        2009-02-18 09:23:21.000000000 +=
0530
+++ r8168-8.011.00-tmp/src/r8168_n.c    2009-05-15 01:40:57.000000000 +=
0530
@@ -808,6 +808,8 @@
        }
 }

+#ifdef CONFIG_PM
+
 static void
 rtl8168_powerup_pll(struct net_device *dev)  { @@ -825,6 +827,8 @@
        rtl8168_set_speed(dev, tp->autoneg, tp->speed, tp->duplex);  }

+#endif /* CONFIG_PM */
+
 static void
 rtl8168_get_wol(struct net_device *dev,
                struct ethtool_wolinfo *wol) @@ -4151,7 +4155,6 @@
rtl8168_tx_clear(struct rtl8168_private *tp)  {
        unsigned int i;
-       struct net_device *dev =3D tp->dev;

        for (i =3D tp->dirty_tx; i < tp->dirty_tx + NUM_TX_DESC; i++) {
                unsigned int entry =3D i % NUM_TX_DESC; @@ -4436,7 +443=
9,7 @@

        tp->tx_skb[entry].len =3D len;
        txd->addr =3D cpu_to_le64(mapping);
-       txd->opts2 =3D cpu_to_le32(rtl8168_tx_vlan_tag(tp, skb));
+       opts2 |=3D cpu_to_le32(rtl8168_tx_vlan_tag(tp, skb));

        wmb();


Rgds,
Nishit Shah.
