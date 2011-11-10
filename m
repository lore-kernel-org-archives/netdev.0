From: Holger Brunck <holger.brunck@keymile.com>
Subject: [PATCH] net, bridge: print log message after state changed
Date: Thu, 10 Nov 2011 17:18:54 +0100
Message-ID: <1320941934-3534-1-git-send-email-holger.brunck@keymile.com>
Cc: Wolfgang Fritz <wolfgang.fritz@keymile.com>,
	Holger Brunck <holger.brunck@keymile.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	bridge@lists.linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.de.keymile.com ([195.8.104.1]:48213 "HELO
	mail.de.keymile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1756692Ab1KJQaI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2011 11:30:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wolfgang Fritz <wolfgang.fritz@keymile.com>

Function br_log_state writes log message "... entering XXXX state" so it
should be called after the state has changed and not before.

Signed-off-by: Wolfgang Fritz <wolfgang.fritz@keymile.com>
Signed-off-by: Holger Brunck <holger.brunck@keymile.com>
cc: Stephen Hemminger <shemminger@linux-foundation.org>
cc: "David S. Miller" <davem@davemloft.net>
cc: bridge@lists.linux-foundation.org
---
 net/bridge/br_stp_if.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/bridge/br_stp_if.c b/net/bridge/br_stp_if.c
index 19308e3..e91be40 100644
--- a/net/bridge/br_stp_if.c
+++ b/net/bridge/br_stp_if.c
@@ -98,8 +98,6 @@ void br_stp_disable_port(struct net_bridge_port *p)
 	struct net_bridge *br = p->br;
 	int wasroot;
 
-	br_log_state(p);
-
 	wasroot = br_is_root_bridge(br);
 	br_become_designated_port(p);
 	p->state = BR_STATE_DISABLED;
@@ -121,6 +119,8 @@ void br_stp_disable_port(struct net_bridge_port *p)
 
 	if (br_is_root_bridge(br) && !wasroot)
 		br_become_root_bridge(br);
+
+	br_log_state(p);
 }
 
 static void br_stp_start(struct net_bridge *br)
-- 
1.7.1
