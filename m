From: Lin Ming <ming.m.lin@intel.com>
Subject: [PATCH -v2] netconsole: switch init_netconsole() to late_initcall
 if build-in
Date: Tue, 13 Sep 2011 15:45:39 +0800
Message-ID: <1315899939.3402.2.camel@snb>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 88491d8(drivers/net: Kconfig & Makefile cleanup) causes a
regression that netconsole does not work if netconsole and network
device driver are build into kernel, because netconsole is linked
before network device driver.

Andrew Morton suggested to fix this with initcall ordering.
Fixes it by switching init_netconsole() to late_initcall if build-in.

Signed-off-by: Lin Ming <ming.m.lin@intel.com>
---
 drivers/net/netconsole.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
index dfc8272..914be29 100644
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -799,5 +799,9 @@ static void __exit cleanup_netconsole(void)
 	}
 }
 
+#ifdef MODULE
 module_init(init_netconsole);
 module_exit(cleanup_netconsole);
+#else
+late_initcall(init_netconsole);
+#endif /* !MODULE */
-- 
1.7.2.5
