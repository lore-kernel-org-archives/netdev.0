From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net 2/3] rtnetlink: bring NETDEV_CHANGELOWERSTATE event process back to rtnetlink_event
Date: Tue, 17 Oct 2017 17:39:40 +0800
Message-ID: <954c1166464c4f08118d80063395a905d9b20912.1508233044.git.lucien.xin@gmail.com>
References: <cover.1508233044.git.lucien.xin@gmail.com>
 <54188a4761376d409cde7bf746edc877b4c3f0ae.1508233044.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net, Jiri Pirko <jiri@resnulli.us>
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:53753 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934809AbdJQJkG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 05:40:06 -0400
Received: by mail-pg0-f65.google.com with SMTP id s2so974451pge.10
        for <netdev@vger.kernel.org>; Tue, 17 Oct 2017 02:40:06 -0700 (PDT)
In-Reply-To: <54188a4761376d409cde7bf746edc877b4c3f0ae.1508233044.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1508233044.git.lucien.xin@gmail.com>
References: <cover.1508233044.git.lucien.xin@gmail.com>
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
index 5ace489..24cb403 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -4292,6 +4292,7 @@ static int rtnetlink_event(struct notifier_block *this, unsigned long event, voi
 	case NETDEV_CHANGEUPPER:
 	case NETDEV_RESEND_IGMP:
 	case NETDEV_CHANGEINFODATA:
+	case NETDEV_CHANGELOWERSTATE:
 	case NETDEV_CHANGE_TX_QUEUE_LEN:
 		rtmsg_ifinfo_event(RTM_NEWLINK, dev, 0, rtnl_get_event(event),
 				   GFP_KERNEL);
-- 
2.1.0
