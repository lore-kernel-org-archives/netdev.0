From: Harish Patil <harish.patil@qlogic.com>
Subject: [PATCH net-next] qlcnic: Fix Kconfig dependency on HWMON
Date: Wed, 7 May 2014 02:06:15 -0400
Message-ID: <1399442775-20610-1-git-send-email-harish.patil@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Shahed Shaikh <shahed.shaikh@qlogic.com>,
	<Dept-HSGLinuxNICDev@qlogic.com>, Arnd Bergmann <arnd@arndb.de>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:5770 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751481AbaEGGf0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 02:35:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 1f0f467b670e "qlcnic: Add hwmon interface to export board
temperature" introduced a randconfig build error in the case
when the hwmon framework is built as a module and the qlcnic
driver itself is built-in:

drivers/built-in.o: In function `qlcnic_register_hwmon_dev':
drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c:1301:
undefined reference to `hwmon_device_register_with_groups'
drivers/built-in.o: In function `qlcnic_unregister_hwmon_dev':
drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c:1309:
undefined reference to `hwmon_device_unregister'.

This changes the Kconfig logic to enforce that the qlcnic hwmon
support can only be enabled if it is possible to successfully
build it.

Signed-off-by: Harish Patil <harish.patil@qlogic.com>
Reported-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/qlogic/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/Kconfig b/drivers/net/ethernet/qlogic/Kconfig
index b818432..d49cba1 100644
--- a/drivers/net/ethernet/qlogic/Kconfig
+++ b/drivers/net/ethernet/qlogic/Kconfig
@@ -68,7 +68,7 @@ config QLCNIC_VXLAN
 
 config QLCNIC_HWMON
 	bool "QLOGIC QLCNIC 82XX and 83XX family HWMON support"
-	depends on QLCNIC && HWMON
+	depends on QLCNIC && HWMON && !(QLCNIC=y && HWMON=m)
 	default y
 	---help---
 	  This configuration parameter can be used to read the
-- 
1.8.1.4
