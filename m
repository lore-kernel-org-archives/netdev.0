From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] team: use a larger struct for mac address
Date: Thu, 20 Jul 2017 16:06:46 -0700
Message-ID: <20170720230646.30364-1-xiyou.wangcong@gmail.com>
Cc: andreyknvl@google.com, Cong Wang <xiyou.wangcong@gmail.com>,
        Jiri Pirko <jiri@resnulli.us>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:34009 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964998AbdGTXGx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Jul 2017 19:06:53 -0400
Received: by mail-pg0-f67.google.com with SMTP id v190so3863818pgv.1
        for <netdev@vger.kernel.org>; Thu, 20 Jul 2017 16:06:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPv6 tunnels use sizeof(struct in6_addr) as dev->addr_len,
but in many places especially bonding, we use struct sockaddr
to copy and set mac addr, this could lead to stack out-of-bounds
access.

Fix it by using a larger address storage like bonding.

Reported-by: Andrey Konovalov <andreyknvl@google.com>
Cc: Jiri Pirko <jiri@resnulli.us>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 drivers/net/team/team.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 464570409796..3c1cdd57db58 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -60,10 +60,10 @@ static struct team_port *team_port_get_rtnl(const struct net_device *dev)
 static int __set_port_dev_addr(struct net_device *port_dev,
 			       const unsigned char *dev_addr)
 {
-	struct sockaddr addr;
+	struct sockaddr_storage addr;
 
-	memcpy(addr.sa_data, dev_addr, port_dev->addr_len);
-	addr.sa_family = port_dev->type;
+	memcpy(addr.__data, dev_addr, port_dev->addr_len);
+	addr.ss_family = port_dev->type;
 	return dev_set_mac_address(port_dev, &addr);
 }
 
-- 
2.13.0
