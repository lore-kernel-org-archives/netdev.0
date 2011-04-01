From: namei.unix@gmail.com
Subject: [PATCH] net/bridge: Fix wrong return-no-vaule
Date: Fri,  1 Apr 2011 12:24:21 +0800
Message-ID: <1301631861-12470-1-git-send-email-namei.unix@gmail.com>
Cc: Liu Yuan <tailai.ly@taobao.com>,
	bridge@lists.linux-foundation.org (open list:ETHERNET BRIDGE),
	netdev@vger.kernel.org (open list:ETHERNET BRIDGE),
	linux-kernel@vger.kernel.org (open list)
To: shemminger@linux-foundation.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Liu Yuan <tailai.ly@taobao.com>

In br_stp_if.c/br_stp_recalculate_bridge_id, it should return
false, which indicates that there is no change when we find
that user has chosen a value.

Signed-off-by: Liu Yuan <tailai.ly@taobao.com>
---
 net/bridge/br_stp_if.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/bridge/br_stp_if.c b/net/bridge/br_stp_if.c
index 5593f5a..9b61d09 100644
--- a/net/bridge/br_stp_if.c
+++ b/net/bridge/br_stp_if.c
@@ -213,7 +213,7 @@ bool br_stp_recalculate_bridge_id(struct net_bridge *br)
 
 	/* user has chosen a value so keep it */
 	if (br->flags & BR_SET_MAC_ADDR)
-		return;
+		return false;
 
 	list_for_each_entry(p, &br->port_list, list) {
 		if (addr == br_mac_zero ||
-- 
1.7.1
