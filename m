From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH RFC 1/3] net: bridge: log state when setting it
Date: Fri, 12 Feb 2016 16:34:18 -0500
Message-ID: <1455312860-24666-2-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1455312860-24666-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jiri@resnulli.us>,
	Scott Feldman <sfeldma@gmail.com>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	Ido Schimmel <idosch@mellanox.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:48921 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751334AbcBLVfE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Feb 2016 16:35:04 -0500
In-Reply-To: <1455312860-24666-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Every call to br_set_state is followed by a call to br_log_state.
Directly call it within br_set_state instead.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/bridge/br_stp.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/bridge/br_stp.c b/net/bridge/br_stp.c
index b3cca12..077afca 100644
--- a/net/bridge/br_stp.c
+++ b/net/bridge/br_stp.c
@@ -52,6 +52,8 @@ void br_set_state(struct net_bridge_port *p, unsigned int state)
 	if (err && err != -EOPNOTSUPP)
 		br_warn(p->br, "error setting offload STP state on port %u(%s)\n",
 				(unsigned int) p->port_no, p->dev->name);
+	else
+		br_log_state(p);
 }
 
 /* called under bridge lock */
@@ -126,7 +128,6 @@ static void br_root_port_block(const struct net_bridge *br,
 		  (unsigned int) p->port_no, p->dev->name);
 
 	br_set_state(p, BR_STATE_LISTENING);
-	br_log_state(p);
 	br_ifinfo_notify(RTM_NEWLINK, p);
 
 	if (br->forward_delay > 0)
@@ -407,7 +408,6 @@ static void br_make_blocking(struct net_bridge_port *p)
 			br_topology_change_detection(p->br);
 
 		br_set_state(p, BR_STATE_BLOCKING);
-		br_log_state(p);
 		br_ifinfo_notify(RTM_NEWLINK, p);
 
 		del_timer(&p->forward_delay_timer);
@@ -431,7 +431,6 @@ static void br_make_forwarding(struct net_bridge_port *p)
 	else
 		br_set_state(p, BR_STATE_LEARNING);
 
-	br_log_state(p);
 	br_ifinfo_notify(RTM_NEWLINK, p);
 
 	if (br->forward_delay != 0)
-- 
2.7.1
