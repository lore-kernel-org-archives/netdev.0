From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 2/3] netdev: Remove redundant checks for CAP_NET_ADMIN in
	MDIO implementations
Date: Thu, 03 Sep 2009 21:39:43 +0100
Message-ID: <1252010383.2781.17.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:55567 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932185AbZICUjn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 16:39:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dev_ioctl() already checks capable(CAP_NET_ADMIN) before calling the
driver's implementation of MDIO ioctls.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
I wrote:
> =EF=BB=BFCurrently most drivers[1] that support the "MII" ioctls allo=
w all users
> to read MDIO registers, while MDIO writes require CAP_NET_ADMIN.

Thankfully this was not true, so I can remove code instead of adding it=
=2E

Ben.

 drivers/net/amd8111e.c          |    3 ---
 drivers/net/atl1c/atl1c_main.c  |    8 --------
 drivers/net/atl1e/atl1e_main.c  |    8 --------
 drivers/net/atlx/atl2.c         |    4 ----
 drivers/net/bnx2.c              |    3 ---
 drivers/net/cassini.c           |    4 ----
 drivers/net/e1000/e1000_main.c  |    4 ----
 drivers/net/e1000e/netdev.c     |    2 --
 drivers/net/ibm_newemac/core.c  |    2 --
 drivers/net/igb/igb_main.c      |    2 --
 drivers/net/mdio.c              |    3 ---
 drivers/net/mii.c               |    3 ---
 drivers/net/natsemi.c           |    2 --
 drivers/net/pci-skeleton.c      |    5 -----
 drivers/net/pcmcia/3c574_cs.c   |    2 --
 drivers/net/pcmcia/axnet_cs.c   |    2 --
 drivers/net/pcmcia/pcnet_cs.c   |    2 --
 drivers/net/pcmcia/xirc2ps_cs.c |    2 --
 drivers/net/phy/phy.c           |    3 ---
 drivers/net/r8169.c             |    2 --
 drivers/net/sis900.c            |    2 --
 drivers/net/skge.c              |    3 ---
 drivers/net/sky2.c              |    3 ---
 drivers/net/sungem.c            |    4 +---
 drivers/net/tg3.c               |    3 ---
 drivers/net/tlan.c              |    2 --
 drivers/net/tulip/tulip_core.c  |    2 --
 drivers/net/tulip/winbond-840.c |    2 --
 drivers/net/via-velocity.c      |    4 ----
 drivers/net/yellowfin.c         |    2 --
 30 files changed, 1 insertions(+), 92 deletions(-)

diff --git a/drivers/net/amd8111e.c b/drivers/net/amd8111e.c
index 98b5f46..4e6359f 100644
--- a/drivers/net/amd8111e.c
+++ b/drivers/net/amd8111e.c
@@ -1524,9 +1524,6 @@ static int amd8111e_ioctl(struct net_device * dev=
 , struct ifreq *ifr, int cmd)
 	int err;
 	u32 mii_regval;
=20
-	if (!capable(CAP_NET_ADMIN))
-		return -EPERM;
-
 	switch(cmd) {
 	case SIOCGMIIPHY:
 		data->phy_id =3D lp->ext_phy_addr;
diff --git a/drivers/net/atl1c/atl1c_main.c b/drivers/net/atl1c/atl1c_m=
ain.c
index e46bf92..be2c6cf 100644
--- a/drivers/net/atl1c/atl1c_main.c
+++ b/drivers/net/atl1c/atl1c_main.c
@@ -534,10 +534,6 @@ static int atl1c_mii_ioctl(struct net_device *netd=
ev,
 		break;
=20
 	case SIOCGMIIREG:
-		if (!capable(CAP_NET_ADMIN)) {
-			retval =3D -EPERM;
-			goto out;
-		}
 		if (atl1c_read_phy_reg(&adapter->hw, data->reg_num & 0x1F,
 				    &data->val_out)) {
 			retval =3D -EIO;
@@ -546,10 +542,6 @@ static int atl1c_mii_ioctl(struct net_device *netd=
ev,
 		break;
=20
 	case SIOCSMIIREG:
-		if (!capable(CAP_NET_ADMIN)) {
-			retval =3D -EPERM;
-			goto out;
-		}
 		if (data->reg_num & ~(0x1F)) {
 			retval =3D -EFAULT;
 			goto out;
diff --git a/drivers/net/atl1e/atl1e_main.c b/drivers/net/atl1e/atl1e_m=
ain.c
index bca127e..69b830f 100644
--- a/drivers/net/atl1e/atl1e_main.c
+++ b/drivers/net/atl1e/atl1e_main.c
@@ -453,10 +453,6 @@ static int atl1e_mii_ioctl(struct net_device *netd=
ev,
 		break;
=20
 	case SIOCGMIIREG:
-		if (!capable(CAP_NET_ADMIN)) {
-			retval =3D -EPERM;
-			goto out;
-		}
 		if (atl1e_read_phy_reg(&adapter->hw, data->reg_num & 0x1F,
 				    &data->val_out)) {
 			retval =3D -EIO;
@@ -465,10 +461,6 @@ static int atl1e_mii_ioctl(struct net_device *netd=
ev,
 		break;
=20
 	case SIOCSMIIREG:
-		if (!capable(CAP_NET_ADMIN)) {
-			retval =3D -EPERM;
-			goto out;
-		}
 		if (data->reg_num & ~(0x1F)) {
 			retval =3D -EFAULT;
 			goto out;
diff --git a/drivers/net/atlx/atl2.c b/drivers/net/atlx/atl2.c
index 10c06b9..ab68886 100644
--- a/drivers/net/atlx/atl2.c
+++ b/drivers/net/atlx/atl2.c
@@ -966,8 +966,6 @@ static int atl2_mii_ioctl(struct net_device *netdev=
, struct ifreq *ifr, int cmd)
 		data->phy_id =3D 0;
 		break;
 	case SIOCGMIIREG:
-		if (!capable(CAP_NET_ADMIN))
-			return -EPERM;
 		spin_lock_irqsave(&adapter->stats_lock, flags);
 		if (atl2_read_phy_reg(&adapter->hw,
 			data->reg_num & 0x1F, &data->val_out)) {
@@ -977,8 +975,6 @@ static int atl2_mii_ioctl(struct net_device *netdev=
, struct ifreq *ifr, int cmd)
 		spin_unlock_irqrestore(&adapter->stats_lock, flags);
 		break;
 	case SIOCSMIIREG:
-		if (!capable(CAP_NET_ADMIN))
-			return -EPERM;
 		if (data->reg_num & ~(0x1F))
 			return -EFAULT;
 		spin_lock_irqsave(&adapter->stats_lock, flags);
diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 1357d54..08cddb6 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -7480,9 +7480,6 @@ bnx2_ioctl(struct net_device *dev, struct ifreq *=
ifr, int cmd)
 	}
=20
 	case SIOCSMIIREG:
-		if (!capable(CAP_NET_ADMIN))
-			return -EPERM;
-
 		if (bp->phy_flags & BNX2_PHY_FLAG_REMOTE_PHY_CAP)
 			return -EOPNOTSUPP;
=20
diff --git a/drivers/net/cassini.c b/drivers/net/cassini.c
index 7517dc1..05916aa 100644
--- a/drivers/net/cassini.c
+++ b/drivers/net/cassini.c
@@ -4875,10 +4875,6 @@ static int cas_ioctl(struct net_device *dev, str=
uct ifreq *ifr, int cmd)
 		break;
=20
 	case SIOCSMIIREG:		/* Write MII PHY register. */
-		if (!capable(CAP_NET_ADMIN)) {
-			rc =3D -EPERM;
-			break;
-		}
 		spin_lock_irqsave(&cp->lock, flags);
 		cas_mif_poll(cp, 0);
 		rc =3D cas_phy_write(cp, data->reg_num & 0x1f, data->val_in);
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_m=
ain.c
index 2c723b1..c66dd4f 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -4714,8 +4714,6 @@ static int e1000_mii_ioctl(struct net_device *net=
dev, struct ifreq *ifr,
 		data->phy_id =3D hw->phy_addr;
 		break;
 	case SIOCGMIIREG:
-		if (!capable(CAP_NET_ADMIN))
-			return -EPERM;
 		spin_lock_irqsave(&adapter->stats_lock, flags);
 		if (e1000_read_phy_reg(hw, data->reg_num & 0x1F,
 				   &data->val_out)) {
@@ -4725,8 +4723,6 @@ static int e1000_mii_ioctl(struct net_device *net=
dev, struct ifreq *ifr,
 		spin_unlock_irqrestore(&adapter->stats_lock, flags);
 		break;
 	case SIOCSMIIREG:
-		if (!capable(CAP_NET_ADMIN))
-			return -EPERM;
 		if (data->reg_num & ~(0x1F))
 			return -EFAULT;
 		mii_reg =3D data->val_in;
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 0f8d961..16c193a 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -4346,8 +4346,6 @@ static int e1000_mii_ioctl(struct net_device *net=
dev, struct ifreq *ifr,
 		data->phy_id =3D adapter->hw.phy.addr;
 		break;
 	case SIOCGMIIREG:
-		if (!capable(CAP_NET_ADMIN))
-			return -EPERM;
 		switch (data->reg_num & 0x1F) {
 		case MII_BMCR:
 			data->val_out =3D adapter->phy_regs.bmcr;
diff --git a/drivers/net/ibm_newemac/core.c b/drivers/net/ibm_newemac/c=
ore.c
index 24ae671..8a95234 100644
--- a/drivers/net/ibm_newemac/core.c
+++ b/drivers/net/ibm_newemac/core.c
@@ -2225,8 +2225,6 @@ static int emac_ioctl(struct net_device *ndev, st=
ruct ifreq *rq, int cmd)
 		return 0;
=20
 	case SIOCSMIIREG:
-		if (!capable(CAP_NET_ADMIN))
-			return -EPERM;
 		emac_mdio_write(ndev, dev->phy.address, data[1], data[2]);
 		return 0;
 	default:
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 7a054d9..56c2228 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -4849,8 +4849,6 @@ static int igb_mii_ioctl(struct net_device *netde=
v, struct ifreq *ifr, int cmd)
 		data->phy_id =3D adapter->hw.phy.addr;
 		break;
 	case SIOCGMIIREG:
-		if (!capable(CAP_NET_ADMIN))
-			return -EPERM;
 		if (igb_read_phy_reg(&adapter->hw, data->reg_num & 0x1F,
 		                     &data->val_out))
 			return -EIO;
diff --git a/drivers/net/mdio.c b/drivers/net/mdio.c
index 7d2e610..21f8754 100644
--- a/drivers/net/mdio.c
+++ b/drivers/net/mdio.c
@@ -380,10 +380,7 @@ int mdio_mii_ioctl(const struct mdio_if_info *mdio=
,
 		cmd =3D SIOCGMIIREG;
 		break;
 	case SIOCGMIIREG:
-		break;
 	case SIOCSMIIREG:
-		if (!capable(CAP_NET_ADMIN))
-			return -EPERM;
 		break;
 	default:
 		return -EOPNOTSUPP;
diff --git a/drivers/net/mii.c b/drivers/net/mii.c
index d81a5d2..210b2b1 100644
--- a/drivers/net/mii.c
+++ b/drivers/net/mii.c
@@ -433,9 +433,6 @@ int generic_mii_ioctl(struct mii_if_info *mii_if,
 	case SIOCSMIIREG: {
 		u16 val =3D mii_data->val_in;
=20
-		if (!capable(CAP_NET_ADMIN))
-			return -EPERM;
-
 		if (mii_data->phy_id =3D=3D mii_if->phy_id) {
 			switch(mii_data->reg_num) {
 			case MII_BMCR: {
diff --git a/drivers/net/natsemi.c b/drivers/net/natsemi.c
index b52e5d9..b2722c4 100644
--- a/drivers/net/natsemi.c
+++ b/drivers/net/natsemi.c
@@ -3075,8 +3075,6 @@ static int netdev_ioctl(struct net_device *dev, s=
truct ifreq *rq, int cmd)
 		return 0;
=20
 	case SIOCSMIIREG:		/* Write MII PHY register. */
-		if (!capable(CAP_NET_ADMIN))
-			return -EPERM;
 		if (dev->if_port =3D=3D PORT_TP) {
 			if ((data->phy_id & 0x1f) =3D=3D np->phy_addr_external) {
  				if ((data->reg_num & 0x1f) =3D=3D MII_ADVERTISE)
diff --git a/drivers/net/pci-skeleton.c b/drivers/net/pci-skeleton.c
index c47ba36..0c44b48 100644
--- a/drivers/net/pci-skeleton.c
+++ b/drivers/net/pci-skeleton.c
@@ -1784,11 +1784,6 @@ static int netdrv_ioctl (struct net_device *dev,=
 struct ifreq *rq, int cmd)
 		break;
=20
 	case SIOCSMIIREG:		/* Write MII PHY register. */
-		if (!capable (CAP_NET_ADMIN)) {
-			rc =3D -EPERM;
-			break;
-		}
-
 		spin_lock_irqsave (&tp->lock, flags);
 		mdio_write (dev, data->phy_id & 0x1f, data->reg_num & 0x1f, data->va=
l_in);
 		spin_unlock_irqrestore (&tp->lock, flags);
diff --git a/drivers/net/pcmcia/3c574_cs.c b/drivers/net/pcmcia/3c574_c=
s.c
index 382d265..d836af1 100644
--- a/drivers/net/pcmcia/3c574_cs.c
+++ b/drivers/net/pcmcia/3c574_cs.c
@@ -1124,8 +1124,6 @@ static int el3_ioctl(struct net_device *dev, stru=
ct ifreq *rq, int cmd)
 			int saved_window;
                        unsigned long flags;
=20
-			if (!capable(CAP_NET_ADMIN))
-				return -EPERM;
 			spin_lock_irqsave(&lp->window_lock, flags);
 			saved_window =3D inw(ioaddr + EL3_CMD) >> 13;
 			EL3WINDOW(4);
diff --git a/drivers/net/pcmcia/axnet_cs.c b/drivers/net/pcmcia/axnet_c=
s.c
index 3b681c1..4f2fef6 100644
--- a/drivers/net/pcmcia/axnet_cs.c
+++ b/drivers/net/pcmcia/axnet_cs.c
@@ -706,8 +706,6 @@ static int axnet_ioctl(struct net_device *dev, stru=
ct ifreq *rq, int cmd)
 	data[3] =3D mdio_read(mii_addr, data[0], data[1] & 0x1f);
 	return 0;
     case SIOCSMIIREG:		/* Write MII PHY register. */
-	if (!capable(CAP_NET_ADMIN))
-	    return -EPERM;
 	mdio_write(mii_addr, data[0], data[1] & 0x1f, data[2]);
 	return 0;
     }
diff --git a/drivers/net/pcmcia/pcnet_cs.c b/drivers/net/pcmcia/pcnet_c=
s.c
index 9ef1c1b..8996b45 100644
--- a/drivers/net/pcmcia/pcnet_cs.c
+++ b/drivers/net/pcmcia/pcnet_cs.c
@@ -1204,8 +1204,6 @@ static int ei_ioctl(struct net_device *dev, struc=
t ifreq *rq, int cmd)
 	data[3] =3D mdio_read(mii_addr, data[0], data[1] & 0x1f);
 	return 0;
     case SIOCSMIIREG:		/* Write MII PHY register. */
-	if (!capable(CAP_NET_ADMIN))
-	    return -EPERM;
 	mdio_write(mii_addr, data[0], data[1] & 0x1f, data[2]);
 	return 0;
     }
diff --git a/drivers/net/pcmcia/xirc2ps_cs.c b/drivers/net/pcmcia/xirc2=
ps_cs.c
index 68de891..9709dd1 100644
--- a/drivers/net/pcmcia/xirc2ps_cs.c
+++ b/drivers/net/pcmcia/xirc2ps_cs.c
@@ -1575,8 +1575,6 @@ do_ioctl(struct net_device *dev, struct ifreq *rq=
, int cmd)
 	data[3] =3D mii_rd(ioaddr, data[0] & 0x1f, data[1] & 0x1f);
 	break;
       case SIOCSMIIREG:		/* Write the specified MII register */
-	if (!capable(CAP_NET_ADMIN))
-	    return -EPERM;
 	mii_wr(ioaddr, data[0] & 0x1f, data[1] & 0x1f, data[2], 16);
 	break;
       default:
diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index eda94fc..6b71b00 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -324,9 +324,6 @@ int phy_mii_ioctl(struct phy_device *phydev,
 		break;
=20
 	case SIOCSMIIREG:
-		if (!capable(CAP_NET_ADMIN))
-			return -EPERM;
-
 		if (mii_data->phy_id =3D=3D phydev->addr) {
 			switch(mii_data->reg_num) {
 			case MII_BMCR:
diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index ec0092a..a91e9b3 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1991,8 +1991,6 @@ static int rtl_xmii_ioctl(struct rtl8169_private =
*tp, struct mii_ioctl_data *dat
 		return 0;
=20
 	case SIOCSMIIREG:
-		if (!capable(CAP_NET_ADMIN))
-			return -EPERM;
 		mdio_write(tp->mmio_addr, data->reg_num & 0x1f, data->val_in);
 		return 0;
 	}
diff --git a/drivers/net/sis900.c b/drivers/net/sis900.c
index d882732..97949d0 100644
--- a/drivers/net/sis900.c
+++ b/drivers/net/sis900.c
@@ -2128,8 +2128,6 @@ static int mii_ioctl(struct net_device *net_dev, =
struct ifreq *rq, int cmd)
 		return 0;
=20
 	case SIOCSMIIREG:		/* Write MII PHY register. */
-		if (!capable(CAP_NET_ADMIN))
-			return -EPERM;
 		mdio_write(net_dev, data->phy_id & 0x1f, data->reg_num & 0x1f, data-=
>val_in);
 		return 0;
 	default:
diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index 1a1e685..62e852e 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -2496,9 +2496,6 @@ static int skge_ioctl(struct net_device *dev, str=
uct ifreq *ifr, int cmd)
 	}
=20
 	case SIOCSMIIREG:
-		if (!capable(CAP_NET_ADMIN))
-			return -EPERM;
-
 		spin_lock_bh(&hw->phy_lock);
 		if (hw->chip_id =3D=3D CHIP_ID_GENESIS)
 			err =3D xm_phy_write(hw, skge->port, data->reg_num & 0x1f,
diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index d1f3b46..ecce1df 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -1213,9 +1213,6 @@ static int sky2_ioctl(struct net_device *dev, str=
uct ifreq *ifr, int cmd)
 	}
=20
 	case SIOCSMIIREG:
-		if (!capable(CAP_NET_ADMIN))
-			return -EPERM;
-
 		spin_lock_bh(&sky2->phy_lock);
 		err =3D gm_phy_write(hw, sky2->port, data->reg_num & 0x1f,
 				   data->val_in);
diff --git a/drivers/net/sungem.c b/drivers/net/sungem.c
index e0dfdd2..305ec3d 100644
--- a/drivers/net/sungem.c
+++ b/drivers/net/sungem.c
@@ -2852,9 +2852,7 @@ static int gem_ioctl(struct net_device *dev, stru=
ct ifreq *ifr, int cmd)
 		break;
=20
 	case SIOCSMIIREG:		/* Write MII PHY register. */
-		if (!capable(CAP_NET_ADMIN))
-			rc =3D -EPERM;
-		else if (!gp->running)
+		if (!gp->running)
 			rc =3D -EAGAIN;
 		else {
 			__phy_write(gp, data->phy_id & 0x1f, data->reg_num & 0x1f,
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index bd49810..7cf8000 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -10610,9 +10610,6 @@ static int tg3_ioctl(struct net_device *dev, st=
ruct ifreq *ifr, int cmd)
 		if (tp->tg3_flags2 & TG3_FLG2_PHY_SERDES)
 			break;			/* We have no PHY */
=20
-		if (!capable(CAP_NET_ADMIN))
-			return -EPERM;
-
 		if (tp->link_config.phy_is_low_power)
 			return -EAGAIN;
=20
diff --git a/drivers/net/tlan.c b/drivers/net/tlan.c
index 49e273b..3d31b47 100644
--- a/drivers/net/tlan.c
+++ b/drivers/net/tlan.c
@@ -1004,8 +1004,6 @@ static int TLan_ioctl(struct net_device *dev, str=
uct ifreq *rq, int cmd)
=20

 	case SIOCSMIIREG:		/* Write MII PHY register. */
-			if (!capable(CAP_NET_ADMIN))
-				return -EPERM;
 			TLan_MiiWriteReg(dev, data->phy_id & 0x1f,
 					 data->reg_num & 0x1f, data->val_in);
 			return 0;
diff --git a/drivers/net/tulip/tulip_core.c b/drivers/net/tulip/tulip_c=
ore.c
index b89b73c..6b2330e 100644
--- a/drivers/net/tulip/tulip_core.c
+++ b/drivers/net/tulip/tulip_core.c
@@ -923,8 +923,6 @@ static int private_ioctl (struct net_device *dev, s=
truct ifreq *rq, int cmd)
 		return 0;
=20
 	case SIOCSMIIREG:		/* Write MII PHY register. */
-		if (!capable (CAP_NET_ADMIN))
-			return -EPERM;
 		if (regnum & ~0x1f)
 			return -EINVAL;
 		if (data->phy_id =3D=3D phy) {
diff --git a/drivers/net/tulip/winbond-840.c b/drivers/net/tulip/winbon=
d-840.c
index 3e59397..b38d3b7 100644
--- a/drivers/net/tulip/winbond-840.c
+++ b/drivers/net/tulip/winbond-840.c
@@ -1470,8 +1470,6 @@ static int netdev_ioctl(struct net_device *dev, s=
truct ifreq *rq, int cmd)
 		return 0;
=20
 	case SIOCSMIIREG:		/* Write MII PHY register. */
-		if (!capable(CAP_NET_ADMIN))
-			return -EPERM;
 		spin_lock_irq(&np->lock);
 		mdio_write(dev, data->phy_id & 0x1f, data->reg_num & 0x1f, data->val=
_in);
 		spin_unlock_irq(&np->lock);
diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index ced1446..e04e5be 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -2328,14 +2328,10 @@ static int velocity_mii_ioctl(struct net_device=
 *dev, struct ifreq *ifr, int cmd
 		miidata->phy_id =3D readb(&regs->MIIADR) & 0x1f;
 		break;
 	case SIOCGMIIREG:
-		if (!capable(CAP_NET_ADMIN))
-			return -EPERM;
 		if (velocity_mii_read(vptr->mac_regs, miidata->reg_num & 0x1f, &(mii=
data->val_out)) < 0)
 			return -ETIMEDOUT;
 		break;
 	case SIOCSMIIREG:
-		if (!capable(CAP_NET_ADMIN))
-			return -EPERM;
 		spin_lock_irqsave(&vptr->lock, flags);
 		err =3D velocity_mii_write(vptr->mac_regs, miidata->reg_num & 0x1f, =
miidata->val_in);
 		spin_unlock_irqrestore(&vptr->lock, flags);
diff --git a/drivers/net/yellowfin.c b/drivers/net/yellowfin.c
index 4987040..40ad0de 100644
--- a/drivers/net/yellowfin.c
+++ b/drivers/net/yellowfin.c
@@ -1365,8 +1365,6 @@ static int netdev_ioctl(struct net_device *dev, s=
truct ifreq *rq, int cmd)
 		return 0;
=20
 	case SIOCSMIIREG:		/* Write MII PHY register. */
-		if (!capable(CAP_NET_ADMIN))
-			return -EPERM;
 		if (data->phy_id =3D=3D np->phys[0]) {
 			u16 value =3D data->val_in;
 			switch (data->reg_num) {

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

