From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH next v2] bonding: Remove unnecessary initialization
Date: Tue,  7 Apr 2015 16:16:29 -0700
Message-ID: <1428448589-2046-1-git-send-email-maheshb@google.com>
Cc: Mahesh Bandewar <maheshb@google.com>,
	Maciej Zenczykowski <maze@google.com>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@gmail.com>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f202.google.com ([209.85.220.202]:33454 "EHLO
	mail-qk0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932101AbbDGXQc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2015 19:16:32 -0400
Received: by qkbx191 with SMTP id x191so8973965qkb.0
        for <netdev@vger.kernel.org>; Tue, 07 Apr 2015 16:16:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bond_3ad_bind_slave() calls ad_initialize_port() and then immediately
assigns correct values making some of that initialization unnecessary.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 drivers/net/bonding/bond_3ad.c | 9 ---------
 1 file changed, 9 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index e2ba211c5c9b..9807ad626474 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -1752,14 +1752,9 @@ static void ad_initialize_port(struct port *port, int lacp_fast)
 	};
 
 	if (port) {
-		port->actor_port_number = 1;
 		port->actor_port_priority = 0xff;
-		port->actor_system = null_mac_addr;
-		port->actor_system_priority = 0xffff;
 		port->actor_port_aggregator_identifier = 0;
 		port->ntt = false;
-		port->actor_admin_port_key = 1;
-		port->actor_oper_port_key  = 1;
 		port->actor_admin_port_state = AD_STATE_AGGREGATION |
 					       AD_STATE_LACP_ACTIVITY;
 		port->actor_oper_port_state  = AD_STATE_AGGREGATION |
@@ -1781,8 +1776,6 @@ static void ad_initialize_port(struct port *port, int lacp_fast)
 		port->sm_mux_state = 0;
 		port->sm_mux_timer_counter = 0;
 		port->sm_tx_state = 0;
-		port->sm_tx_timer_counter = 0;
-		port->slave = NULL;
 		port->aggregator = NULL;
 		port->next_port_in_aggregator = NULL;
 		port->transaction_id = 0;
@@ -1973,8 +1966,6 @@ void bond_3ad_bind_slave(struct slave *slave)
 		 * lacpdu's are sent in one second)
 		 */
 		port->sm_tx_timer_counter = ad_ticks_per_sec/AD_MAX_TX_IN_SECOND;
-		port->aggregator = NULL;
-		port->next_port_in_aggregator = NULL;
 
 		__disable_port(port);
 
-- 
2.2.0.rc0.207.ga3a616c
