From: Vaibhav Hiremath <hvaibhav@ti.com>
Subject: [PATCH-V2 0/4] ARM: AM33XX: net: Add DT support to CPGMAC and MDIO driver
Date: Mon, 29 Oct 2012 13:51:17 +0530
Message-ID: <1351498881-32482-2-git-send-email-hvaibhav@ti.com>
References: <1351498881-32482-1-git-send-email-hvaibhav@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <paul@pwsan.com>, <linux-arm-kernel@lists.infradead.org>,
	<linux-omap@vger.kernel.org>, Vaibhav Hiremath <hvaibhav@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:50809 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756427Ab2J2IVc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2012 04:21:32 -0400
In-Reply-To: <1351498881-32482-1-git-send-email-hvaibhav@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch-series adds support for,

[1/4]: Typo mistake in CPSW driver while invoking runtime_pm api's

[2/4]: Adds parent<->child relation between CPSW & MDIO module inside cpsw
       driver, as in case of AM33XX, the resources are shared and common
       register bit-field is provided to control module/clock enable/disable,
       makes it difficult to handle common resource.

       So the solution here is, to create parent<->child relation between them.

[3/4]: Add hwmod entry for MDIO module, required for MDIO driver.

[4/4]: Add DT device nodes for both CPSW and MDIO modules in am33xx.dtsi,
	am335x-evm.dts and am335x-bone.dts file

This patch series has been created on top of linux-omap/master and tested
on both AM335x-EVM and BeagleBone platforms for NFS boot and basic ping
test cases.


All the patches are also available at,

git@github.com:hvaibhav/am335x-linux.git  am335x-upstream-staging-cpsw


Mugunthan V N (2):
  ARM: OMAP3+: hwmod: Add AM33XX HWMOD data for davinci_mdio module
  arm/dts: am33xx: Add CPSW and MDIO module nodes for AM33XX

Vaibhav Hiremath (2):
  net: davinci_mdio: Fix typo mistake in calling runtime-pm api
  net: cpsw: Add parent<->child relation support between cpsw and mdio

 arch/arm/boot/dts/am335x-bone.dts          |    8 ++++
 arch/arm/boot/dts/am335x-evm.dts           |    8 ++++
 arch/arm/boot/dts/am33xx.dtsi              |   50 ++++++++++++++++++++++++++++
 arch/arm/mach-omap2/omap_hwmod_33xx_data.c |   32 ++++++++++++++++++
 drivers/net/ethernet/ti/cpsw.c             |   16 ++++++++-
 drivers/net/ethernet/ti/davinci_mdio.c     |    2 +-
 6 files changed, 113 insertions(+), 3 deletions(-)
