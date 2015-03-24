From: <cmetcalf@ezchip.com>
Subject: [PATCH 4/4] net: tile: don't send interrupts to nohz cores by default
Date: Tue, 24 Mar 2015 15:21:35 -0400
Message-ID: <1427224895-30830-5-git-send-email-cmetcalf@ezchip.com>
References: <1427224895-30830-1-git-send-email-cmetcalf@ezchip.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Chris Metcalf <cmetcalf@ezchip.com>
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Ingo Molnar <mingo@kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Peter Zijlstra <peterz@infradead.org>,
	Borislav Petkov <bp@alien8.de>,
	Li Zhong <zhong@linux.vnet.ibm.com>,
	Mike Galbraith <efault@gmx.de>,
	Kevin Hilman <khilman@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0080.outbound.protection.outlook.com ([157.56.112.80]:48639
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755119AbbCXTWr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Mar 2015 15:22:47 -0400
In-Reply-To: <1427224895-30830-1-git-send-email-cmetcalf@ezchip.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chris Metcalf <cmetcalf@ezchip.com>

Signed-off-by: Chris Metcalf <cmetcalf@ezchip.com>
---
 drivers/net/ethernet/tile/tilegx.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/tile/tilegx.c b/drivers/net/ethernet/tile/tilegx.c
index bea8cd2bb56c..cf9850c6a809 100644
--- a/drivers/net/ethernet/tile/tilegx.c
+++ b/drivers/net/ethernet/tile/tilegx.c
@@ -40,6 +40,7 @@
 #include <linux/tcp.h>
 #include <linux/net_tstamp.h>
 #include <linux/ptp_clock_kernel.h>
+#include <linux/tick.h>
 
 #include <asm/checksum.h>
 #include <asm/homecache.h>
@@ -2271,8 +2272,10 @@ static int __init tile_net_init_module(void)
 	for (i = 0; gxio_mpipe_link_enumerate_mac(i, name, mac) >= 0; i++)
 		tile_net_dev_init(name, mac);
 
-	if (!network_cpus_init())
+	if (!network_cpus_init()) {
 		network_cpus_map = *cpu_online_mask;
+		tick_nohz_full_clear_cpus(&network_cpus_map);
+	}
 
 	return 0;
 }
-- 
2.1.2
