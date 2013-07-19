From: Jiri Slaby <jslaby@suse.cz>
Subject: [PATCH] NET: pch_gbe depends on x86
Date: Fri, 19 Jul 2013 08:26:09 +0200
Message-ID: <1374215169-28866-1-git-send-email-jslaby@suse.cz>
References: <51d48037.Zcczkb6ouQ0Nv+4v%fengguang.wu@intel.com>
Cc: linux-kernel@vger.kernel.org, Jiri Slaby <jslaby@suse.cz>,
	Ben Hutchings <ben@decadent.org.uk>, netdev@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	kbuild-all@01.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51d48037.Zcczkb6ouQ0Nv+4v%fengguang.wu@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since 4bb1667255a86360721291fe59991d033bbc2f2a (build some drivers only
when compile-testing), PTP_1588_CLOCK_PCH depends on (X86 ||
COMPILE_TEST). But PCH_GBE selects PTP_1588_CLOCK_PCH without
depending on x86. Fix this by adding the same dependency here.

Signed-off-by: Jiri Slaby <jslaby@suse.cz>
Reported-by: <fengguang.wu@intel.com> [intel's build test robot]
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Ben Hutchings <ben@decadent.org.uk>
Cc: netdev@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: kbuild-all@01.org
---
 drivers/net/ethernet/oki-semi/pch_gbe/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig b/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig
index cb22341..a588ffd 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig
@@ -4,7 +4,7 @@
 
 config PCH_GBE
 	tristate "OKI SEMICONDUCTOR IOH(ML7223/ML7831) GbE"
-	depends on PCI
+	depends on PCI && (X86 || COMPILE_TEST)
 	select MII
 	select PTP_1588_CLOCK_PCH
 	---help---
-- 
1.8.3.1
