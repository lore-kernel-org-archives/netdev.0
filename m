From: Mahesh Bandewar <mahesh@bandewar.net>
Subject: [PATCH next 3/5] bonding: remove hardcoded value
Date: Wed,  8 Mar 2017 10:55:56 -0800
Message-ID: <20170308185556.23069-1-mahesh@bandewar.net>
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
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34700 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751600AbdCHTEA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Mar 2017 14:04:00 -0500
Received: by mail-pf0-f195.google.com with SMTP id o126so4664004pfb.1
        for <netdev@vger.kernel.org>; Wed, 08 Mar 2017 11:02:57 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>

Eliminate hard-coded value and use the default that is set.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 drivers/net/bonding/bond_main.c | 14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 1329110ed85f..0f9f5ceae80e 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4254,6 +4254,7 @@ static int bond_check_params(struct bond_params *params)
 	int arp_all_targets_value;
 	u16 ad_actor_sys_prio = 0;
 	u16 ad_user_port_key = 0;
+	int tlb_dynamic_lb = 0;
 
 	/* Convert string parameters. */
 	if (mode) {
@@ -4566,6 +4567,17 @@ static int bond_check_params(struct bond_params *params)
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
@@ -4593,7 +4605,7 @@ static int bond_check_params(struct bond_params *params)
 	params->min_links = min_links;
 	params->lp_interval = lp_interval;
 	params->packets_per_slave = packets_per_slave;
-	params->tlb_dynamic_lb = 1; /* Default value */
+	params->tlb_dynamic_lb = tlb_dynamic_lb;
 	params->ad_actor_sys_prio = ad_actor_sys_prio;
 	eth_zero_addr(params->ad_actor_system);
 	params->ad_user_port_key = ad_user_port_key;
-- 
2.12.0.246.ga2ecc84866-goog
