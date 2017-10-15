From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net 4/6] rtnetlink: bring NETDEV_CHANGEUPPER event process back in rtnetlink_event
Date: Sun, 15 Oct 2017 18:13:44 +0800
Message-ID: <784f477a1f9e8b9a5ec7bbe9e1dff1dcdfd5553b.1508062280.git.lucien.xin@gmail.com>
References: <cover.1508062280.git.lucien.xin@gmail.com>
 <d7713874f0ad1c19b640eaae98f0d554d1743a4c.1508062280.git.lucien.xin@gmail.com>
 <e240a6572c8e495eb2da15bd6178604cdfde08ba.1508062280.git.lucien.xin@gmail.com>
 <b4125c6cf42d4d028a9c04f4989627ac1eb83257.1508062280.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net, David Ahern <dsahern@gmail.com>,
        hannes@stressinduktion.org
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:57218 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751480AbdJOKO1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 15 Oct 2017 06:14:27 -0400
Received: by mail-pf0-f193.google.com with SMTP id b85so13631265pfj.13
        for <netdev@vger.kernel.org>; Sun, 15 Oct 2017 03:14:27 -0700 (PDT)
In-Reply-To: <b4125c6cf42d4d028a9c04f4989627ac1eb83257.1508062280.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1508062280.git.lucien.xin@gmail.com>
References: <cover.1508062280.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

libteam needs this event notification in userspace when dev's master
dev has been changed. After this, the redundant notifications issue
would be fixed in the later patch 'rtnetlink: check DO_SETLINK_NOTIFY
correctly in do_setlink'.

Fixes: b6b36eb23a46 ("rtnetlink: Do not generate notifications for NETDEV_CHANGEUPPER event")
Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/core/rtnetlink.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 8e44fd5..ab98c1c 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -4286,6 +4286,7 @@ static int rtnetlink_event(struct notifier_block *this, unsigned long event, voi
 	case NETDEV_BONDING_FAILOVER:
 	case NETDEV_POST_TYPE_CHANGE:
 	case NETDEV_NOTIFY_PEERS:
+	case NETDEV_CHANGEUPPER:
 	case NETDEV_RESEND_IGMP:
 	case NETDEV_CHANGEINFODATA:
 	case NETDEV_CHANGE_TX_QUEUE_LEN:
-- 
2.1.0
