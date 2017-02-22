From: Mahesh Bandewar <mahesh@bandewar.net>
Subject: [PATCH next 3/4] bonding: remove hardcoded value
Date: Tue, 21 Feb 2017 17:08:28 -0800
Message-ID: <20170222010828.9887-1-mahesh@bandewar.net>
Cc: netdev <netdev@vger.kernel.org>,
        Mahesh Bandewar <mahesh@bandewar.net>,
        Mahesh Bandewar <maheshb@google.com>
To: Jay Vosburgh <j.vosburgh@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>,
        Veaceslav Falico <vfalico@gmail.com>,
        Nikolay Aleksandrov <nikolay@redhat.com>,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:35005 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753531AbdBVBIb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 20:08:31 -0500
Received: by mail-pg0-f66.google.com with SMTP id 1so13642962pgz.2
        for <netdev@vger.kernel.org>; Tue, 21 Feb 2017 17:08:31 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>

Eliminate hard-coded value and use the default that is set.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 drivers/net/bonding/bond_main.c | 14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index b7a344ffc1de..06ac1783bfdd 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4253,6 +4253,7 @@ static int bond_check_params(struct bond_params *params)
 	int arp_all_targets_value;
 	u16 ad_actor_sys_prio = 0;
 	u16 ad_user_port_key = 0;
+	int tlb_dynamic_lb = 0;
 
 	/* Convert string parameters. */
 	if (mode) {
@@ -4565,6 +4566,17 @@ static int bond_check_params(struct bond_params *params)
 	}
 	ad_user_port_key = valptr->value;
 
+	if (bond_mode == BOND_MODE_TLB) {
+		bond_opt_initstr(&newval, "default");
+		valptr = bond_opt_parse(bond_opt_get(BOND_OPT_TLB_DYNAMIC_LB),
+					&newval);
+		if (!valptr) {
+			pr_err("Error: No tlb_dynamic_lb default value");
+			return -EINVAL;
+		}
+		tlb_dynamic_lb = valptr->value;
+	}
+
 	if (lp_interval == 0) {
 		pr_warn("Warning: ip_interval must be between 1 and %d, so it was reset to %d\n",
 			INT_MAX, BOND_ALB_DEFAULT_LP_INTERVAL);
@@ -4592,7 +4604,7 @@ static int bond_check_params(struct bond_params *params)
 	params->min_links = min_links;
 	params->lp_interval = lp_interval;
 	params->packets_per_slave = packets_per_slave;
-	params->tlb_dynamic_lb = 1; /* Default value */
+	params->tlb_dynamic_lb = tlb_dynamic_lb;
 	params->ad_actor_sys_prio = ad_actor_sys_prio;
 	eth_zero_addr(params->ad_actor_system);
 	params->ad_user_port_key = ad_user_port_key;
-- 
2.11.0.483.g087da7b7c-goog
