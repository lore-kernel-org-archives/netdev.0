From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Wed, 17 Feb 2016 11:56:07 +1100
Message-ID: <20160217115607.720d3d44@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Florian Fainelli <f.fainelli@gmail.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  drivers/net/phy/bcm7xxx.c

between commit:

  c6dd213abe40 ("net: phy: bcm7xxx: Fix 40nm EPHY features")
  815717d1473e ("net: phy: bcm7xxx: Remove wildcard entries"

from the net tree and commit:

  3125c081a593 ("net: phy: bcm7xxx: Reduce boilerplate code for 40nm EPHY")

from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

-- 
Cheers,
Stephen Rothwell

diff --cc drivers/net/phy/bcm7xxx.c
index db507e3bcab9,9b311041ebfb..000000000000
--- a/drivers/net/phy/bcm7xxx.c
+++ b/drivers/net/phy/bcm7xxx.c
@@@ -247,9 -247,13 +247,9 @@@ static int bcm7xxx_config_init(struct p
  	int ret;
  
  	/* Enable 64 clock MDIO */
- 	phy_write(phydev, MII_BCM7XXX_AUX_MODE, MII_BCM7XX_64CLK_MDIO);
+ 	phy_write(phydev, MII_BCM7XXX_AUX_MODE, MII_BCM7XXX_64CLK_MDIO);
  	phy_read(phydev, MII_BCM7XXX_AUX_MODE);
  
 -	/* Workaround only required for 100Mbits/sec capable PHYs */
 -	if (phydev->supported & PHY_GBIT_FEATURES)
 -		return 0;
 -
  	/* set shadow mode 2 */
  	ret = phy_set_clr_bits(phydev, MII_BCM7XXX_TEST,
  			MII_BCM7XXX_SHD_MODE_2, MII_BCM7XXX_SHD_MODE_2);
@@@ -324,43 -348,34 +339,10 @@@ static struct phy_driver bcm7xxx_driver
  	BCM7XXX_28NM_GPHY(PHY_ID_BCM7439, "Broadcom BCM7439"),
  	BCM7XXX_28NM_GPHY(PHY_ID_BCM7439_2, "Broadcom BCM7439 (2)"),
  	BCM7XXX_28NM_GPHY(PHY_ID_BCM7445, "Broadcom BCM7445"),
- {
- 	.phy_id         = PHY_ID_BCM7425,
- 	.phy_id_mask    = 0xfffffff0,
- 	.name           = "Broadcom BCM7425",
- 	.features       = PHY_BASIC_FEATURES |
- 			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,
- 	.flags          = PHY_IS_INTERNAL,
- 	.config_init    = bcm7xxx_config_init,
- 	.config_aneg    = genphy_config_aneg,
- 	.read_status    = genphy_read_status,
- 	.suspend        = bcm7xxx_suspend,
- 	.resume         = bcm7xxx_config_init,
- }, {
- 	.phy_id         = PHY_ID_BCM7429,
- 	.phy_id_mask    = 0xfffffff0,
- 	.name           = "Broadcom BCM7429",
- 	.features       = PHY_BASIC_FEATURES |
- 			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,
- 	.flags          = PHY_IS_INTERNAL,
- 	.config_init    = bcm7xxx_config_init,
- 	.config_aneg    = genphy_config_aneg,
- 	.read_status    = genphy_read_status,
- 	.suspend        = bcm7xxx_suspend,
- 	.resume         = bcm7xxx_config_init,
- }, {
- 	.phy_id         = PHY_ID_BCM7435,
- 	.phy_id_mask    = 0xfffffff0,
- 	.name           = "Broadcom BCM7435",
- 	.features       = PHY_BASIC_FEATURES |
- 			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,
- 	.flags          = PHY_IS_INTERNAL,
- 	.config_init    = bcm7xxx_config_init,
- 	.config_aneg    = genphy_config_aneg,
- 	.read_status    = genphy_read_status,
- 	.suspend        = bcm7xxx_suspend,
- 	.resume         = bcm7xxx_config_init,
- } };
+ 	BCM7XXX_40NM_EPHY(PHY_ID_BCM7425, "Broadcom BCM7425"),
+ 	BCM7XXX_40NM_EPHY(PHY_ID_BCM7429, "Broadcom BCM7429"),
+ 	BCM7XXX_40NM_EPHY(PHY_ID_BCM7435, "Broadcom BCM7435"),
 -{
 -	.phy_id		= PHY_BCM_OUI_4,
 -	.phy_id_mask	= 0xffff0000,
 -	.name		= "Broadcom BCM7XXX 40nm",
 -	.features	= PHY_GBIT_FEATURES |
 -			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,
 -	.flags		= PHY_IS_INTERNAL,
 -	.config_init	= bcm7xxx_config_init,
 -	.config_aneg	= genphy_config_aneg,
 -	.read_status	= genphy_read_status,
 -	.suspend	= bcm7xxx_suspend,
 -	.resume		= bcm7xxx_config_init,
 -}, {
 -	.phy_id		= PHY_BCM_OUI_5,
 -	.phy_id_mask	= 0xffffff00,
 -	.name		= "Broadcom BCM7XXX 65nm",
 -	.features	= PHY_BASIC_FEATURES |
 -			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,
 -	.flags		= PHY_IS_INTERNAL,
 -	.config_init	= bcm7xxx_dummy_config_init,
 -	.config_aneg	= genphy_config_aneg,
 -	.read_status	= genphy_read_status,
 -	.suspend	= bcm7xxx_suspend,
 -	.resume		= bcm7xxx_config_init,
 -} };
++};
  
  static struct mdio_device_id __maybe_unused bcm7xxx_tbl[] = {
  	{ PHY_ID_BCM7250, 0xfffffff0, },
