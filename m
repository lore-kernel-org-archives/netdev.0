From: Mahesh Bandewar <mahesh@bandewar.net>
Subject: [PATCH next 5/5] bonding: reduce scope of some global variables
Date: Wed,  8 Mar 2017 10:56:02 -0800
Message-ID: <20170308185602.23203-1-mahesh@bandewar.net>
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
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35063 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753880AbdCHTEA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Mar 2017 14:04:00 -0500
Received: by mail-pg0-f65.google.com with SMTP id 187so4221268pgb.2
        for <netdev@vger.kernel.org>; Wed, 08 Mar 2017 11:03:38 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>

Many of the bond param variables are declared global while it's not
really necessary for these variables to be global. So moving them to
the location these are used.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 drivers/net/bonding/bond_main.c | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 0f9f5ceae80e..ba934020dfaa 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -201,12 +201,6 @@ atomic_t netpoll_block_tx = ATOMIC_INIT(0);
 
 unsigned int bond_net_id __read_mostly;
 
-static __be32 arp_target[BOND_MAX_ARP_TARGETS];
-static int arp_ip_count;
-static int bond_mode	= BOND_MODE_ROUNDROBIN;
-static int xmit_hashtype = BOND_XMIT_POLICY_LAYER2;
-static int lacp_fast;
-
 /*-------------------------- Forward declarations ---------------------------*/
 
 static int bond_init(struct net_device *bond_dev);
@@ -4254,6 +4248,11 @@ static int bond_check_params(struct bond_params *params)
 	int arp_all_targets_value;
 	u16 ad_actor_sys_prio = 0;
 	u16 ad_user_port_key = 0;
+	__be32 arp_target[BOND_MAX_ARP_TARGETS];
+	int arp_ip_count;
+	int bond_mode	= BOND_MODE_ROUNDROBIN;
+	int xmit_hashtype = BOND_XMIT_POLICY_LAYER2;
+	int lacp_fast = 0;
 	int tlb_dynamic_lb = 0;
 
 	/* Convert string parameters. */
-- 
2.12.0.246.ga2ecc84866-goog
