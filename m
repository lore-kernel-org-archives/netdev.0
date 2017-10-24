From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv3 net-next 3/4] rtnetlink: bring NETDEV_CHANGELOWERSTATE event process back to rtnetlink_event
Date: Tue, 24 Oct 2017 13:54:19 +0800
Message-ID: <3f83956d2d0f3e4548aa60878ca09dc41c8bcc3f.1508824093.git.lucien.xin@gmail.com>
References: <cover.1508824093.git.lucien.xin@gmail.com>
 <7e91d225f138a96c791574d050c95679c08c80d8.1508824093.git.lucien.xin@gmail.com>
 <1e175dc56b1dbd2a42ce7c8e6fc29d6c19185240.1508824093.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net, David Ahern <dsahern@gmail.com>,
        Jiri Pirko <jiri@resnulli.us>
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:52645 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751535AbdJXFyx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 01:54:53 -0400
Received: by mail-pg0-f66.google.com with SMTP id a192so13660600pge.9
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 22:54:53 -0700 (PDT)
In-Reply-To: <1e175dc56b1dbd2a42ce7c8e6fc29d6c19185240.1508824093.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1508824093.git.lucien.xin@gmail.com>
References: <cover.1508824093.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to bring NETDEV_CHANGELOWERSTATE event process back
to rtnetlink_event so that bonding could use it instead of calling
rtmsg_ifinfo to send a notification to userspace after netdev lower
state is changed in the later patch.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/core/rtnetlink.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index df8dba9..854a848 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -4385,6 +4385,7 @@ static int rtnetlink_event(struct notifier_block *this, unsigned long event, voi
 	case NETDEV_CHANGEUPPER:
 	case NETDEV_RESEND_IGMP:
 	case NETDEV_CHANGEINFODATA:
+	case NETDEV_CHANGELOWERSTATE:
 	case NETDEV_CHANGE_TX_QUEUE_LEN:
 		rtmsg_ifinfo_event(RTM_NEWLINK, dev, 0, rtnl_get_event(event),
 				   GFP_KERNEL, NULL);
-- 
2.1.0
