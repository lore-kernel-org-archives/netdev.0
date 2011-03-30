From: Dongdong Deng <dongdong.deng@windriver.com>
Subject: [PATCH] bridge: return value for br_stp_recalculate_bridge_id()
Date: Wed, 30 Mar 2011 14:23:27 +0800
Message-ID: <1301466207-16770-1-git-send-email-dongdong.deng@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <bridge@lists.linux-foundation.org>,
	<dongdong.deng@windriver.com>
To: <davem@davemloft.net>, <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:64822 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751070Ab1C3GVK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2011 02:21:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Return 'false' for "user has set a mac addr" case in
br_stp_recalculate_bridge_id() function.

and this could address the following build warning:

net/bridge/br_stp_if.c: In function br_stp_recalculate_bridge_id:
net/bridge/br_stp_if.c:216: warning: return with no value, in function
returning non-void

Signed-off-by: Dongdong Deng <dongdong.deng@windriver.com>
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
1.6.0.4

