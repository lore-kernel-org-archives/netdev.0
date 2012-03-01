From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Subject: [PATCH 2/2] bridge: message age needs to increase, not decrease.
Date: Thu, 1 Mar 2012 19:12:19 +0100
Message-ID: <1330625539-10247-2-git-send-email-Joakim.Tjernlund@transmode.se>
References: <1330625539-10247-1-git-send-email-Joakim.Tjernlund@transmode.se>
Cc: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([195.58.98.146]:32893 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755796Ab2CASM1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Mar 2012 13:12:27 -0500
Received: from mail1.transmode.se (mail1.transmode.se [192.168.201.18])
	by gw1.transmode.se (Postfix) with ESMTP id BD30D258374
	for <netdev@vger.kernel.org>; Thu,  1 Mar 2012 19:12:26 +0100 (CET)
In-Reply-To: <1330625539-10247-1-git-send-email-Joakim.Tjernlund@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit bridge: send proper message_age in config BPDU
added this gem:
  bpdu.message_age = (jiffies - root->designated_age)
  p->designated_age = jiffies + bpdu->message_age;
Notice how bpdu->message_age is negated when reassigned to
bpdu.message_age. This causes message age to decrease breaking the
STP protocol.

Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
---

The bridge list seems very slow so try netdev instead.

 net/bridge/br_stp.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/bridge/br_stp.c b/net/bridge/br_stp.c
index 9a8aebd..45331fe 100644
--- a/net/bridge/br_stp.c
+++ b/net/bridge/br_stp.c
@@ -188,7 +188,7 @@ static inline void br_record_config_information(struct net_bridge_port *p,
 	p->designated_cost = bpdu->root_path_cost;
 	p->designated_bridge = bpdu->bridge_id;
 	p->designated_port = bpdu->port_id;
-	p->designated_age = jiffies + bpdu->message_age;
+	p->designated_age = jiffies - bpdu->message_age;
 
 	mod_timer(&p->message_age_timer, jiffies
 		  + (p->br->max_age - bpdu->message_age));
-- 
1.7.3.4
