From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: [PATCH] net/ehea: bitops work on unsigned longs
Date: Wed, 31 Dec 2008 14:18:53 +1100
Message-ID: <20081231141853.c6d123c4.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ppc-dev <linuxppc-dev@ozlabs.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:38425 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752673AbYLaDSz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Dec 2008 22:18:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These changes will avoid several warnings when we change u64 to unsigned
long long.

Also, ehea_driver_flags is only used in ehca_main.c

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 drivers/net/ehea/ehea.h      |    3 +--
 drivers/net/ehea/ehea_main.c |    2 +-
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ehea/ehea.h b/drivers/net/ehea/ehea.h
index 9930d5f..6271b94 100644
--- a/drivers/net/ehea/ehea.h
+++ b/drivers/net/ehea/ehea.h
@@ -478,7 +478,7 @@ struct ehea_port {
 	int num_add_tx_qps;
 	int num_mcs;
 	int resets;
-	u64 flags;
+	unsigned long flags;
 	u64 mac_addr;
 	u32 logical_port_id;
 	u32 port_speed;
@@ -510,7 +510,6 @@ void ehea_set_ethtool_ops(struct net_device *netdev);
 int ehea_sense_port_attr(struct ehea_port *port);
 int ehea_set_portspeed(struct ehea_port *port, u32 port_speed);
 
-extern u64 ehea_driver_flags;
 extern struct work_struct ehea_rereg_mr_task;
 
 #endif	/* __EHEA_H__ */
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index a2f1905..e3131ea 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -99,7 +99,7 @@ MODULE_PARM_DESC(use_lro, " Large Receive Offload, 1: enable, 0: disable, "
 
 static int port_name_cnt;
 static LIST_HEAD(adapter_list);
-u64 ehea_driver_flags;
+static unsigned long ehea_driver_flags;
 struct work_struct ehea_rereg_mr_task;
 static DEFINE_MUTEX(dlpar_mem_lock);
 struct ehea_fw_handle_array ehea_fw_handles;
-- 
1.6.0.5

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/
