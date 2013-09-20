From: Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>
Subject: [net-next PATCH 0/4] cpsw: support for control module register
Date: Sat, 21 Sep 2013 00:50:37 +0530
Message-ID: <1379704841-32693-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <zonque-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <bcousson-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>,
	<tony-4v6yS6AI5VpBDgjK7y7TUQ@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch series adds the support for configuring GMII_SEL register
of control module to select the phy mode type and also to configure
the clock source for RMII phy mode whether to use internal clock or
the external clock from the phy itself.

Till now CPSW works as this configuration is done in U-Boot and carried
over to the kernel. But during suspend/resume Control module tends to
lose its configured value for GMII_SEL register in AM33xx PG1.0, so
if CPSW is used in RMII or RGMII mode, on resume cpsw is not working
as GMII_SEL register lost its configuration values.

The initial version of the patch is done by Daniel Mack but as per
Tony's comment he wants it as a seperate driver as it is done in USB
control module. I have created a seperate driver for the same.

Changes from RFC version:
* Changed "_" to "-" in DT names as per Serger's comment

Daniel Mack (1):
  net: ethernet: cpsw: switch to devres allocations

Mugunthan V N (3):
  drivers: net: cpsw-phy-sel: Add new driver for phy mode selection for
    cpsw
  drivers: net: cpsw: use cpsw-phy-sel driver to configure phy mode
  ARM: dts: am33xx: adopt to cpsw-phy-sel driver to configure phy mode

 .../devicetree/bindings/net/cpsw-phy-sel.txt       |  28 ++++
 arch/arm/boot/dts/am33xx.dtsi                      |   6 +
 drivers/net/ethernet/ti/Kconfig                    |   8 +
 drivers/net/ethernet/ti/Makefile                   |   1 +
 drivers/net/ethernet/ti/cpsw-phy-sel.c             | 161 +++++++++++++++++++++
 drivers/net/ethernet/ti/cpsw.c                     | 157 ++++++--------------
 drivers/net/ethernet/ti/cpsw.h                     |   2 +
 7 files changed, 253 insertions(+), 110 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/cpsw-phy-sel.txt
 create mode 100644 drivers/net/ethernet/ti/cpsw-phy-sel.c

-- 
1.8.4

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
