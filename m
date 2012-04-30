From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Subject: [PATCH] bridge: make brctl showstp display port id
Date: Mon, 30 Apr 2012 10:39:08 +0200
Message-ID: <1335775148-5191-1-git-send-email-Joakim.Tjernlund@transmode.se>
Cc: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([195.58.98.146]:54660 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753361Ab2D3IjL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Apr 2012 04:39:11 -0400
Received: from mail1.transmode.se (mail1.transmode.se [192.168.201.18])
	by gw1.transmode.se (Postfix) with ESMTP id BE81A25803A
	for <netdev@vger.kernel.org>; Mon, 30 Apr 2012 10:39:10 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

My brctl showstp br0 always shows a 0 port id:
eth2 (1)
 port id		0			state		       disabled
 designated root	8000.00069c00b2fb	path cost		 100

because port id is printed as a hex number in sys fs. Change the
two hex occurrences(port no and port id) to decimal, just like all
the other numbers in this area.

Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
---
 net/bridge/br_sysfs_if.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/bridge/br_sysfs_if.c b/net/bridge/br_sysfs_if.c
index fd5799c..9c4c2eb 100644
--- a/net/bridge/br_sysfs_if.c
+++ b/net/bridge/br_sysfs_if.c
@@ -86,13 +86,13 @@ static BRPORT_ATTR(designated_cost, S_IRUGO, show_designated_cost, NULL);
 
 static ssize_t show_port_id(struct net_bridge_port *p, char *buf)
 {
-	return sprintf(buf, "0x%x\n", p->port_id);
+	return sprintf(buf, "%d\n", p->port_id);
 }
 static BRPORT_ATTR(port_id, S_IRUGO, show_port_id, NULL);
 
 static ssize_t show_port_no(struct net_bridge_port *p, char *buf)
 {
-	return sprintf(buf, "0x%x\n", p->port_no);
+	return sprintf(buf, "%d\n", p->port_no);
 }
 
 static BRPORT_ATTR(port_no, S_IRUGO, show_port_no, NULL);
-- 
1.7.3.4
