From: Michal Simek <michal.simek@xilinx.com>
Subject: [PATCH v2 5/5] phy: Add Marvell 88E1510 phy ID
Date: Fri, 31 May 2013 08:08:27 +0200
Message-ID: <4c8d1aa315b3abc569f4134d4301488ea510b2e8.1369980470.git.michal.simek@xilinx.com>
References: <cover.1369980470.git.michal.simek@xilinx.com>
Content-Type: multipart/signed;
    boundary="=_mimegpg-monstr-desktop-1726-1369980520-0001";
    micalg=pgp-sha1; protocol="application/pgp-signature"
Cc: Michal Simek <monstr@monstr.eu>,
	Michal Simek <michal.simek@xilinx.com>,
	"David S. Miller" <davem@davemloft.net>,
	Lars-Peter Clausen <lars@metafoo.de>,
	Christian Hohnstaedt <chohnstaedt@innominate.com>,
	Rick Hoover <RHoover@digilentinc.com>,
	Anirudha Sarangi <anirudh@xilinx.com>,
	Steven Wang <steven.wang@digilentinc.com>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1369980470.git.michal.simek@xilinx.com>
In-Reply-To: <cover.1369980470.git.michal.simek@xilinx.com>
References: <cover.1369980470.git.michal.simek@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a MIME GnuPG-signed message.  If you see this text, it means that
your E-mail or Usenet software does not support MIME signed messages.
The Internet standard for MIME PGP messages, RFC 2015, was published in 1996.
To open this message correctly you will need to install E-mail or Usenet
software that supports modern Internet standards.

--=_mimegpg-monstr-desktop-1726-1369980520-0001

Add support for this new phy ID.

Signed-off-by: Rick Hoover <RHoover@digilentinc.com>
Signed-off-by: Steven Wang <steven.wang@digilentinc.com>
Signed-off-by: Lars-Peter Clausen <lars@metafoo.de>
Signed-off-by: Michal Simek <michal.simek@xilinx.com>
---
Changes in v2:
- None

 drivers/net/phy/marvell.c   | 25 +++++++++++++++++++++++++
 include/linux/marvell_phy.h |  1 +
 2 files changed, 26 insertions(+)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index df5a9f6..2e91477 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -374,6 +374,17 @@ static int m88e1318_config_aneg(struct phy_device *phydev)
 	return m88e1121_config_aneg(phydev);
 }

+static int m88e1510_config_aneg(struct phy_device *phydev)
+{
+	int err;
+
+	err = m88e1318_config_aneg(phydev);
+	if (err < 0)
+		return err;
+
+	return marvell_of_reg_init(phydev);
+}
+
 static int m88e1116r_config_init(struct phy_device *phydev)
 {
 	int temp;
@@ -1004,6 +1015,19 @@ static struct phy_driver marvell_drivers[] = {
 		.config_intr = &marvell_config_intr,
 		.driver = { .owner = THIS_MODULE },
 	},
+	{
+		.phy_id = MARVELL_PHY_ID_88E1510,
+		.phy_id_mask = MARVELL_PHY_ID_MASK,
+		.name = "Marvell 88E1510",
+		.features = PHY_GBIT_FEATURES,
+		.flags = PHY_HAS_INTERRUPT,
+		.config_aneg = &m88e1510_config_aneg,
+		.read_status = &marvell_read_status,
+		.ack_interrupt = &marvell_ack_interrupt,
+		.config_intr = &marvell_config_intr,
+		.did_interrupt = &m88e1121_did_interrupt,
+		.driver = { .owner = THIS_MODULE },
+	},
 };

 static int __init marvell_init(void)
@@ -1032,6 +1056,7 @@ static struct mdio_device_id __maybe_unused marvell_tbl[] = {
 	{ MARVELL_PHY_ID_88E1240, MARVELL_PHY_ID_MASK },
 	{ MARVELL_PHY_ID_88E1318S, MARVELL_PHY_ID_MASK },
 	{ MARVELL_PHY_ID_88E1116R, MARVELL_PHY_ID_MASK },
+	{ MARVELL_PHY_ID_88E1510, MARVELL_PHY_ID_MASK },
 	{ }
 };

diff --git a/include/linux/marvell_phy.h b/include/linux/marvell_phy.h
index ec41025..8e9a029 100644
--- a/include/linux/marvell_phy.h
+++ b/include/linux/marvell_phy.h
@@ -15,6 +15,7 @@
 #define MARVELL_PHY_ID_88E1240		0x01410e30
 #define MARVELL_PHY_ID_88E1318S		0x01410e90
 #define MARVELL_PHY_ID_88E1116R		0x01410e40
+#define MARVELL_PHY_ID_88E1510		0x01410dd0

 /* struct phy_device dev_flags definitions */
 #define MARVELL_PHY_M1145_FLAGS_RESISTANCE	0x00000001
--
1.8.2.3


--=_mimegpg-monstr-desktop-1726-1369980520-0001
Content-Type: application/pgp-signature
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAlGoPmgACgkQykllyylKDCEGdgCeK2P3rJWXdFXOJmTLnFZDSzG8
29YAni+dsXgcja6DoIjjCaazfX1OflIt
=htLZ
-----END PGP SIGNATURE-----

--=_mimegpg-monstr-desktop-1726-1369980520-0001--
