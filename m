From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v2 1/3] bonding: add option lp_interval for loading
 module
Date: Sat, 21 Dec 2013 14:40:12 +0800
Message-ID: <52B537CC.1040305@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Veaceslav Falico <vfalico@redhat.com>,
	Netdev <netdev@vger.kernel.org>,
	Scott Feldman <sfeldma@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:19129 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751166Ab3LUGkr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Dec 2013 01:40:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bond driver could set the lp_interval when loading module.

Suggested-by: Scott Feldman <sfeldma@cumulusnetworks.com>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_main.c | 15 +++++++++++++--
 1 file changed, 13 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index c0456cc..368f7e4 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -113,6 +113,7 @@ static int all_slaves_active;
 static struct bond_params bonding_defaults;
 static int resend_igmp = BOND_DEFAULT_RESEND_IGMP;
 static int packets_per_slave = 1;
+static int lp_interval = BOND_ALB_DEFAULT_LP_INTERVAL;
 
 module_param(max_bonds, int, 0);
 MODULE_PARM_DESC(max_bonds, "Max number of bonded devices");
@@ -189,7 +190,11 @@ module_param(packets_per_slave, int, 0);
 MODULE_PARM_DESC(packets_per_slave, "Packets to send per slave in balance-rr "
 				    "mode; 0 for a random slave, 1 packet per "
 				    "slave (default), >1 packets per slave.");
-
+module_param(lp_interval, uint, 0);
+MODULE_PARM_DESC(lp_interval, "The number of seconds between instances where "
+			      "the bonding driver sends learning packets to "
+			      "each slaves peer switch. The default is 1.");
+	
 /*----------------------------- Global variables ----------------------------*/
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -4271,6 +4276,12 @@ static int bond_check_params(struct bond_params *params)
 		fail_over_mac_value = BOND_FOM_NONE;
 	}
 
+	if (lp_interval == 0) {
+		pr_warning("Warning: ip_interval must be between 1 and %d, so it was reset to %d\n",
+			   INT_MAX, BOND_ALB_DEFAULT_LP_INTERVAL);
+		lp_interval = BOND_ALB_DEFAULT_LP_INTERVAL;
+	}
+
 	/* fill params struct with the proper values */
 	params->mode = bond_mode;
 	params->xmit_policy = xmit_hashtype;
@@ -4290,7 +4301,7 @@ static int bond_check_params(struct bond_params *params)
 	params->all_slaves_active = all_slaves_active;
 	params->resend_igmp = resend_igmp;
 	params->min_links = min_links;
-	params->lp_interval = BOND_ALB_DEFAULT_LP_INTERVAL;
+	params->lp_interval = lp_interval;
 	if (packets_per_slave > 1)
 		params->packets_per_slave = reciprocal_value(packets_per_slave);
 	else
-- 
1.8.0
