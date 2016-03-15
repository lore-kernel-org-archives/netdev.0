From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] bus: mvebu-mbus: use %pad to print phys_addr_t
Date: Tue, 15 Mar 2016 11:03:39 +0100
Message-ID: <1458036233-2770406-1-git-send-email-arnd@arndb.de>
Cc: Marcin Wojtas <mw@semihalf.com>, Evan Wang <xswang@marvell.com>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>,
	netdev@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Nicolas Schichan <nschichan@freebox.fr>,
	linux-kernel@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.134]:49745 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964916AbcCOKEO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2016 06:04:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A recent change to the mbus driver added a warning printk that
prints a phys_addr_t using the %x format string, which fails in
case we build with 64-bit phys_addr_t:

drivers/bus/mvebu-mbus.c: In function 'mvebu_mbus_get_dram_win_info':
drivers/bus/mvebu-mbus.c:975:9: error: format '%x' expects argument of type 'unsigned int', but argument 2 has type 'phys_addr_t {aka long long unsigned int}' [-Werror=format=]

This uses the special %pa format string instead, so we always
print the correct type.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: f2900acea801 ("bus: mvebu-mbus: provide api for obtaining IO and DRAM window information")
---
The warning was introduced in today's linux-next through the net-next
tree, please apply this fixup on top.

 drivers/bus/mvebu-mbus.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/bus/mvebu-mbus.c b/drivers/bus/mvebu-mbus.c
index c2e52864bb03..ce54a0160faa 100644
--- a/drivers/bus/mvebu-mbus.c
+++ b/drivers/bus/mvebu-mbus.c
@@ -972,7 +972,7 @@ int mvebu_mbus_get_dram_win_info(phys_addr_t phyaddr, u8 *target, u8 *attr)
 		}
 	}
 
-	pr_err("invalid dram address 0x%x\n", phyaddr);
+	pr_err("invalid dram address %pa\n", &phyaddr);
 	return -EINVAL;
 }
 EXPORT_SYMBOL_GPL(mvebu_mbus_get_dram_win_info);
-- 
2.7.0
