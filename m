From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Problem with sky2 (Yukon-EC)
Date: Mon, 30 Jun 2008 12:54:14 -0700
Message-ID: <20080630125414.3876f342@extreme>
References: <Pine.LNX.4.64.0806302104141.4958@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Krzysztof Oledzki <olel@ans.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:33866 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764213AbYF3TyU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2008 15:54:20 -0400
In-Reply-To: <Pine.LNX.4.64.0806302104141.4958@bizon.gios.gov.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 30 Jun 2008 21:28:15 +0200 (CEST)
Krzysztof Oledzki <olel@ans.pl> wrote:

> Hello,
>=20
> I have several servers with sky2 NIC (bonding + vlan):
>=20
> sky2 0000:02:00.0: v1.20 addr 0xcfffc000 irq 17 Yukon-EC (0xb6) rev 1
>=20
> 02:00.0 Ethernet controller: Marvell Technology Group Ltd. 88E8053 PC=
I-E Gigabit Ethernet Controller (rev 15)
>          Subsystem: ASUSTeK Computer Inc. Marvell 88E8053 Gigabit Eth=
ernet controller PCIe (Asus)
>          Flags: bus master, fast devsel, latency 0, IRQ 221
>          Memory at cfffc000 (64-bit, non-prefetchable) [size=3D16K]
>          I/O ports at d800 [size=3D256]
>          Expansion ROM at cffc0000 [disabled] [size=3D128K]
>          Capabilities: [48] Power Management version 2
>          Capabilities: [50] Vital Product Data <?>
>          Capabilities: [5c] Message Signalled Interrupts: Mask- 64bit=
+ Queue=3D0/1 Enable+
>          Capabilities: [e0] Express Legacy Endpoint, MSI 00
>          Kernel driver in use: sky2
>=20
> All server suffer the same problem - once about two-three weeks netwo=
rk=20
> dies completely (log from 2.6.24):
>=20
> sky2 eth1: hung mac 7:19 fifo 0 (91:101)
> sky2 eth1: receiver hang detected
> sky2 eth1: disabling interface
> sky2 eth1: enabling interface
> bonding: bond0: link status definitely down for interface eth1, disab=
ling it
> bonding: bond0: now running without any active interface !
> sky2 eth1: Link is up at 100 Mbps, full duplex, flow control both
> bonding: bond0: link status definitely up for interface eth1.
> bonding: bond0: making interface eth1 the new active one.
> bonding: bond0: first active interface up!
> sky2 eth1: rx length error: status 0x402500 length 64
> *last message repeated 9 times
> kernel: sky2 eth1: rx length error: status 0x402300 length 64
> kernel: sky2 eth1: rx length error: status 0x402500 length 64
> *last message repeated 7 times
> *last message repeated 6 times
> kernel: sky2 eth1: rx length error: status 0x402300 length 64
> kernel: sky2 eth1: rx length error: status 0x402500 length 64
> (...)
>=20
> Similar log from 2.6.22:
> sky2 eth0: tx timeout
> sky2 eth0: transmit ring 141 .. 119 report=3D141 done=3D141
> sky2 eth0: disabling interface
> sky2 eth0: enabling interface
> sky2 eth0: ram buffer 48K
> bonding: bond0: link status definitely down for interface eth0, disab=
ling it
> bonding: bond0: making interface eth1 the new active one.
> sky2 eth0: Link is up at 100 Mbps, full duplex, flow control both
> bonding: bond0: link status definitely up for interface eth0.
> bonding: bond0: making interface eth0 the new active one.
> sky2 eth0: rx error, status 0x402300 length 64
> sky2 eth0: rx error, status 0x402300 length 64
> sky2 eth0: rx error, status 0x402300 length 64
> sky2 eth0: rx error, status 0x402300 length 64
> sky2 eth0: rx error, status 0x402300 length 64
> sky2 eth0: rx error, status 0x402300 length 64
> sky2 eth0: rx error, status 0x402300 length 64
> sky2 eth0: rx error, status 0x402300 length 64
> sky2 eth0: rx error, status 0x402300 length 64
> sky2 eth0: rx error, status 0x402300 length 64
> sky2 eth0: rx error, status 0x402300 length 64
> sky2 eth0: rx error, status 0x402300 length 64
> sky2 eth0: rx error, status 0x402300 length 64
> sky2 eth0: rx error, status 0x402300 length 64
> sky2 eth0: rx error, status 0x8a2100 length 138
> sky2 eth0: rx error, status 0x8a2100 length 138
> sky2 eth0: rx error, status 0x9a2100 length 154
> sky2 eth0: rx error, status 0xba2100 length 186
> sky2 eth0: rx error, status 0x5e2100 length 94
> sky2 eth0: rx error, status 0xba2100 length 186
> sky2 eth0: rx error, status 0xea2100 length 234
> sky2 eth0: rx error, status 0x8a2100 length 138
> sky2 eth0: rx error, status 0x8a2100 length 138
> sky2 eth0: rx error, status 0xea2100 length 234
> sky2 eth0: rx error, status 0x8a2100 length 138
> (...)
>=20
> It seems that there is somethig wrong with the receiver hang workarou=
nd=20
> code. After such reset the card is not longer able to receive traffic=
=2E=20
> Maybe it is somehow related to vlans?
>=20
> This problem exists in 2.6.21/2.6.22/2.6.24. I have not yet tested=20
> 2.6.25/2.6.26, any chances it get fixed there?
>=20
> Best regards,
>=20
>  				Krzysztof Ol=C4=99dzki

There was a fix to reset vlan offloading in 2.6.26

commit d494eacde8858f9b53f5c640692caf14eb3c8239
Author: Stephen Hemminger <shemminger@vyatta.com>
Date:   Wed May 14 17:04:13 2008 -0700

    sky2: restore vlan acceleration on reset
   =20
    If device has to be reset by sky2_restart, then need to restore
    the VLAN acceleration settings.
   =20
    Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
    Signed-off-by: Jeff Garzik <jgarzik@redhat.com>

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index f226bca..3bb6053 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -1159,17 +1159,9 @@ static int sky2_ioctl(struct net_device *dev, st=
ruct ifreq *ifr, int cmd)
 }
=20
 #ifdef SKY2_VLAN_TAG_USED
-static void sky2_vlan_rx_register(struct net_device *dev, struct vlan_=
group *grp)
+static void sky2_set_vlan_mode(struct sky2_hw *hw, u16 port, bool onof=
f)
 {
-	struct sky2_port *sky2 =3D netdev_priv(dev);
-	struct sky2_hw *hw =3D sky2->hw;
-	u16 port =3D sky2->port;
-
-	netif_tx_lock_bh(dev);
-	napi_disable(&hw->napi);
-
-	sky2->vlgrp =3D grp;
-	if (grp) {
+	if (onoff) {
 		sky2_write32(hw, SK_REG(port, RX_GMF_CTRL_T),
 			     RX_VLAN_STRIP_ON);
 		sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T),
@@ -1180,6 +1172,19 @@ static void sky2_vlan_rx_register(struct net_dev=
ice *dev, struct vlan_group *grp
 		sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T),
 			     TX_VLAN_TAG_OFF);
 	}
+}
+
+static void sky2_vlan_rx_register(struct net_device *dev, struct vlan_=
group *grp)
+{
+	struct sky2_port *sky2 =3D netdev_priv(dev);
+	struct sky2_hw *hw =3D sky2->hw;
+	u16 port =3D sky2->port;
+
+	netif_tx_lock_bh(dev);
+	napi_disable(&hw->napi);
+
+	sky2->vlgrp =3D grp;
+	sky2_set_vlan_mode(hw, port, grp !=3D NULL);
=20
 	sky2_read32(hw, B0_Y2_SP_LISR);
 	napi_enable(&hw->napi);
@@ -1418,6 +1423,10 @@ static int sky2_up(struct net_device *dev)
 	sky2_prefetch_init(hw, txqaddr[port], sky2->tx_le_map,
 			   TX_RING_SIZE - 1);
=20
+#ifdef SKY2_VLAN_TAG_USED
+	sky2_set_vlan_mode(hw, port, sky2->vlgrp !=3D NULL);
+#endif
+
 	err =3D sky2_rx_start(sky2);
 	if (err)
 		goto err_out;




