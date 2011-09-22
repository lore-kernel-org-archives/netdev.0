From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: [PATCH -next] seeq: fix compile breakage on s390
Date: Thu, 22 Sep 2011 09:42:06 +0200
Message-ID: <1316677326-6081-1-git-send-email-heiko.carstens@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The SEEQ drivers should depend on HAS_IOMEM to prevent compile breakage
on !HAS_IOMEM architectures:

drivers/net/ethernet/seeq/seeq8005.c: In function 'seeq8005_probe1':
drivers/net/ethernet/seeq/seeq8005.c:179:2: error:
  implicit declaration of function 'inw' [-Werror=implicit-function-declaration]

Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
---
 drivers/net/ethernet/seeq/Kconfig |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/seeq/Kconfig b/drivers/net/ethernet/seeq/Kconfig
index 49b6d5b..29f1853 100644
--- a/drivers/net/ethernet/seeq/Kconfig
+++ b/drivers/net/ethernet/seeq/Kconfig
@@ -5,6 +5,7 @@
 config NET_VENDOR_SEEQ
 	bool "SEEQ devices"
 	default y
+	depends on HAS_IOMEM
 	depends on (ARM && ARCH_ACORN) || SGI_HAS_SEEQ || EXPERIMENTAL
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
-- 
1.7.5.4
