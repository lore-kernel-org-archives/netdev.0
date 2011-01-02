From: =?UTF-8?q?Nicolas=20de=20Peslo=C3=BCan?=
	<nicolas.2p.debian@free.fr>
Subject: [PATCH net-next-2.6] bonding: remove meaningless /sys/module/bonding/parameters entries.
Date: Sun,  2 Jan 2011 15:35:15 +0100
Message-ID: <1293978915-29674-1-git-send-email-nicolas.2p.debian@free.fr>
Cc: nicolas.2p.debian@free.fr
To: bonding-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	fubar@us.ibm.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6-g21.free.fr ([212.27.42.6]:50118 "EHLO smtp6-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754565Ab1ABOfl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Jan 2011 09:35:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Only two bonding parameters are exposed in /sys/module/bonding:

num_grat_arp
num_unsol_na

Those values are not module global, but per device.

The per device values are available in /sys/class/net/<device>/bonding.

The values exposed in /sys/module/bonding are those given at module load time
and only used as default values when creating a device. They are read-only and
cannot change in any way.

As such, they are mostly meaningless.
---
 drivers/net/bonding/bond_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index b1025b8..b7fd966 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -116,9 +116,9 @@ module_param(max_bonds, int, 0);
 MODULE_PARM_DESC(max_bonds, "Max number of bonded devices");
 module_param(tx_queues, int, 0);
 MODULE_PARM_DESC(tx_queues, "Max number of transmit queues (default = 16)");
-module_param(num_grat_arp, int, 0644);
+module_param(num_grat_arp, int, 0);
 MODULE_PARM_DESC(num_grat_arp, "Number of gratuitous ARP packets to send on failover event");
-module_param(num_unsol_na, int, 0644);
+module_param(num_unsol_na, int, 0);
 MODULE_PARM_DESC(num_unsol_na, "Number of unsolicited IPv6 Neighbor Advertisements packets to send on failover event");
 module_param(miimon, int, 0);
 MODULE_PARM_DESC(miimon, "Link check interval in milliseconds");
-- 
1.7.2.3

