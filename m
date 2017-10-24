From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv3 net-next 1/4] bridge: remove rtmsg_ifinfo called in add_del_if
Date: Tue, 24 Oct 2017 13:54:17 +0800
Message-ID: <7e91d225f138a96c791574d050c95679c08c80d8.1508824093.git.lucien.xin@gmail.com>
References: <cover.1508824093.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net, David Ahern <dsahern@gmail.com>,
        Jiri Pirko <jiri@resnulli.us>
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:55366 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750989AbdJXFyh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 01:54:37 -0400
Received: by mail-pf0-f195.google.com with SMTP id 17so18892288pfn.12
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 22:54:37 -0700 (PDT)
In-Reply-To: <cover.1508824093.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1508824093.git.lucien.xin@gmail.com>
References: <cover.1508824093.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit dc709f375743 ("rtnetlink: bring NETDEV_CHANGEUPPER event
process back in rtnetlink_event"), rtnetlink_event would process the
NETDEV_CHANGEUPPER event and send a notification to userspace.

In add_del_if, it would generate NETDEV_CHANGEUPPER event by whether
netdev_master_upper_dev_link or netdev_upper_dev_unlink. There's
no need to call rtmsg_ifinfo to send the notification any more.

So this patch is to remove it from add_del_if also to avoid redundant
notifications.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/bridge/br_ioctl.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/net/bridge/br_ioctl.c b/net/bridge/br_ioctl.c
index 8f29103..16d01a3 100644
--- a/net/bridge/br_ioctl.c
+++ b/net/bridge/br_ioctl.c
@@ -102,9 +102,6 @@ static int add_del_if(struct net_bridge *br, int ifindex, int isadd)
 	else
 		ret = br_del_if(br, dev);
 
-	if (!ret)
-		rtmsg_ifinfo(RTM_NEWLINK, dev, IFF_MASTER, GFP_KERNEL);
-
 	return ret;
 }
 
-- 
2.1.0
