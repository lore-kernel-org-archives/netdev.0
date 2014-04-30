From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] qlcnic: clarify hwmon Kconfig dependency
Date: Wed, 30 Apr 2014 11:15:14 +0200
Message-ID: <4879713.xMSSnUPZKf@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>,
	Dept-HSGLinuxNICDev@qlogic.com,
	Harish Patil <harish.patil@qlogic.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.187]:51363 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758684AbaD3J1X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2014 05:27:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 1f0f467b670e "qlcnic: Add hwmon interface to export board
temperature" introduced a randconfig build error in the case
when the hwmon framework is built as a module and the qlcnic
driver itself is built-in:

drivers/built-in.o: In function `qlcnic_register_hwmon_dev':
drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c:1301: undefined reference to `hwmon_device_register_with_groups'
drivers/built-in.o: In function `qlcnic_unregister_hwmon_dev':
drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c:1309: undefined reference to `hwmon_device_unregister'

This changes the Kconfig logic to enforce that the qlcnic hwmon
support can only be enabled if it is possible to successfully
build it.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Cc: Harish Patil <harish.patil@qlogic.com>

diff --git a/drivers/net/ethernet/qlogic/Kconfig b/drivers/net/ethernet/qlogic/Kconfig
index 0482adb..9493824 100644
--- a/drivers/net/ethernet/qlogic/Kconfig
+++ b/drivers/net/ethernet/qlogic/Kconfig
@@ -69,6 +69,7 @@ config QLCNIC_VXLAN
 config QLCNIC_HWMON
 	bool "QLOGIC QLCNIC 82XX and 83XX family HWMON support"
 	depends on QLCNIC && HWMON
+	depends on QLCNIC=m || HWMON=y
 	default y
 	---help---
 	  This configuration parameter can be used to read the
