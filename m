From: Vlad Tsyrklevich <vlad@tsyrklevich.net>
Subject: [PATCH] net/appletalk: Fix kernel memory disclosure
Date: Mon,  9 Jan 2017 20:57:48 +0700
Message-ID: <1483970268-6145-1-git-send-email-vlad@tsyrklevich.net>
Cc: netdev@vger.kernel.org, Vlad Tsyrklevich <vlad@tsyrklevich.net>
To: acme@ghostprotocols.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:33333 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S942422AbdAIN7I (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 08:59:08 -0500
Received: by mail-pg0-f67.google.com with SMTP id 194so7316275pgd.0
        for <netdev@vger.kernel.org>; Mon, 09 Jan 2017 05:59:07 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ipddp_route structs contain alignment padding so kernel heap memory
is leaked when they are copied to user space in
ipddp_ioctl(SIOCFINDIPDDPRT). Change kmalloc() to kzalloc() to clear
that memory.

Signed-off-by: Vlad Tsyrklevich <vlad@tsyrklevich.net>
---
 drivers/net/appletalk/ipddp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/appletalk/ipddp.c b/drivers/net/appletalk/ipddp.c
index b8c2933..a306de4 100644
--- a/drivers/net/appletalk/ipddp.c
+++ b/drivers/net/appletalk/ipddp.c
@@ -190,7 +190,7 @@ static netdev_tx_t ipddp_xmit(struct sk_buff *skb, struct net_device *dev)
  */
 static int ipddp_create(struct ipddp_route *new_rt)
 {
-        struct ipddp_route *rt = kmalloc(sizeof(*rt), GFP_KERNEL);
+        struct ipddp_route *rt = kzalloc(sizeof(*rt), GFP_KERNEL);
 
         if (rt == NULL)
                 return -ENOMEM;
-- 
2.7.0
