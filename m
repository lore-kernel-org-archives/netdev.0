From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] ssb: host_soc depends on sprom
Date: Wed, 13 Jan 2016 23:51:43 +0100
Message-ID: <8128014.DbbgBtKY3z@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: =?utf-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>,
	Hauke Mehrtens <hauke@hauke-m.de>, Michael Buesch <m@bues.ch>,
	linux-mips@linux-mips.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Drivers that use the SSB sprom functionality typically 'select SSB_SPROM'
from Kconfig, but CONFIG_SSB_HOST_SOC misses this, which results in
a build failure unless at least one of the other drivers that selects
it is enabled:

drivers/built-in.o: In function `ssb_host_soc_get_invariants':
(.text+0x459494): undefined reference to `ssb_fill_sprom_with_fallback'

This adds the same select statement that is used elsewhere.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: 541c9a84cd85 ("ssb: pick SoC invariants code from MIPS BCM47xx arch")
---
I'm not sure who the right person is to pick up the fix. The patch that
introduced the problem was merged by Kalle through the iwlwifi tree.

diff --git a/drivers/ssb/Kconfig b/drivers/ssb/Kconfig
index 0c675861623f..d8e4219c2324 100644
--- a/drivers/ssb/Kconfig
+++ b/drivers/ssb/Kconfig
@@ -83,6 +83,7 @@ config SSB_SDIOHOST
 config SSB_HOST_SOC
 	bool "Support for SSB bus on SoC"
 	depends on SSB && BCM47XX_NVRAM
+	select SSB_SPROM
 	help
 	  Host interface for a SSB directly mapped into memory. This is
 	  for some Broadcom SoCs from the BCM47xx and BCM53xx lines.
