From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next 2/2] team: use RCU_INIT_POINTER for NULL assignment of RCU pointer
Date: Wed, 20 Jun 2012 17:32:01 +0200
Message-ID: <1340206321-5986-3-git-send-email-jpirko@redhat.com>
References: <1340206321-5986-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com, jbrouer@redhat.com,
	paulmck@linux.vnet.ibm.com, wfg@linux.intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42022 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755680Ab2FTPcz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jun 2012 11:32:55 -0400
In-Reply-To: <1340206321-5986-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/team/team_mode_loadbalance.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/team/team_mode_loadbalance.c b/drivers/net/team/team_mode_loadbalance.c
index b4475a5..c385b45 100644
--- a/drivers/net/team/team_mode_loadbalance.c
+++ b/drivers/net/team/team_mode_loadbalance.c
@@ -97,7 +97,7 @@ static void lb_tx_hash_to_port_mapping_null_port(struct team *team,
 
 		pm = &lb_priv->ex->tx_hash_to_port_mapping[i];
 		if (rcu_access_pointer(pm->port) == port) {
-			rcu_assign_pointer(pm->port, NULL);
+			RCU_INIT_POINTER(pm->port, NULL);
 			team_option_inst_set_change(pm->opt_inst_info);
 			changed = true;
 		}
-- 
1.7.10.4
