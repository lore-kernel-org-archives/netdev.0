From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH] powerpc/83xx: Enable FIXED_PHY in mpc834x_itx and mpc83xx
	defconfigs
Date: Thu, 4 Dec 2008 20:52:31 +0300
Message-ID: <20081204175231.GA28554@oksana.dev.rtsoft.ru>
References: <ed82fe3e0812040915i696e99bep75a37b0e38154415@mail.gmail.com>
Reply-To: avorontsov@ru.mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	afleming@freescale.com
To: Kumar Gala <galak@kernel.crashing.org>,
	Timur Tabi <timur@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft3.corbina.net ([85.21.88.6]:6569 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753677AbYLDRwd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2008 12:52:33 -0500
Content-Disposition: inline
In-Reply-To: <ed82fe3e0812040915i696e99bep75a37b0e38154415@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is needed so that Vitesse 7385 5-port switch could work on
MPC8349E-mITX boards.

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---

On Thu, Dec 04, 2008 at 11:15:32AM -0600, Timur Tabi wrote:
> The Freescale MPC8349e-MITX reference board has two TSECs, the second
> of which (eth1) is attached to a Vitesse 7385 5-port switch.
> 
> Using the latest U-Boot, Kernel, and device tree, I cannot bring up
> eth1.  When I try, I get this message:
> 
> [root@tintin root]# ifconfig eth1 up
> 0:01 not found
> eth1: Could not attach to PHY
> SIOCSIFFLAGS: No such device
> 
> Unfortunately, I don't even know what this means.

The FIXED_PHY driver isn't enabled in the defconfig. Following
patch should fix the issue.

 arch/powerpc/configs/83xx/mpc834x_itx_defconfig |    2 +-
 arch/powerpc/configs/mpc83xx_defconfig          |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/powerpc/configs/83xx/mpc834x_itx_defconfig b/arch/powerpc/configs/83xx/mpc834x_itx_defconfig
index e55ff7c..07a674f 100644
--- a/arch/powerpc/configs/83xx/mpc834x_itx_defconfig
+++ b/arch/powerpc/configs/83xx/mpc834x_itx_defconfig
@@ -723,7 +723,7 @@ CONFIG_CICADA_PHY=y
 # CONFIG_BROADCOM_PHY is not set
 # CONFIG_ICPLUS_PHY is not set
 # CONFIG_REALTEK_PHY is not set
-# CONFIG_FIXED_PHY is not set
+CONFIG_FIXED_PHY=y
 # CONFIG_MDIO_BITBANG is not set
 # CONFIG_NET_ETHERNET is not set
 CONFIG_NETDEV_1000=y
diff --git a/arch/powerpc/configs/mpc83xx_defconfig b/arch/powerpc/configs/mpc83xx_defconfig
index 15eb30c..d582014 100644
--- a/arch/powerpc/configs/mpc83xx_defconfig
+++ b/arch/powerpc/configs/mpc83xx_defconfig
@@ -682,7 +682,7 @@ CONFIG_VITESSE_PHY=y
 # CONFIG_BROADCOM_PHY is not set
 CONFIG_ICPLUS_PHY=y
 # CONFIG_REALTEK_PHY is not set
-# CONFIG_FIXED_PHY is not set
+CONFIG_FIXED_PHY=y
 # CONFIG_MDIO_BITBANG is not set
 CONFIG_NET_ETHERNET=y
 CONFIG_MII=y
-- 
1.5.6.5

