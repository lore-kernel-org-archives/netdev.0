From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] bridge: netlink status fix
Date: Wed, 2 Aug 2006 16:53:23 -0700
Message-ID: <20060802165323.39c66900@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:7910 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750728AbWHBXxt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2006 19:53:49 -0400
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix code that passes back netlink status messages about
bridge changes. Submitted by Aji_Srinivas@emc.com

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
---
 net/bridge/br_netlink.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 06abb66..53086fb 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -85,7 +85,7 @@ void br_ifinfo_notify(int event, struct 
 		goto err_out;
 
 	err = br_fill_ifinfo(skb, port, current->pid, 0, event, 0);
-	if (err)
+	if (err < 0)
 		goto err_kfree;
 
 	NETLINK_CB(skb).dst_group = RTNLGRP_LINK;
-- 
1.4.0


-- 
