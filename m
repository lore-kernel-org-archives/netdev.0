From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv2 net-next 2/3] rtnetlink: bring NETDEV_CHANGELOWERSTATE event process back to rtnetlink_event
Date: Mon, 23 Oct 2017 18:44:51 +0800
Message-ID: <8ca1a0080c9ef1dd81750f69967cec324f1e8a84.1508755319.git.lucien.xin@gmail.com>
References: <cover.1508755319.git.lucien.xin@gmail.com>
 <15984f2370698158ef2af599b8619a2b7f64852d.1508755319.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net, Jiri Pirko <jiri@resnulli.us>
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:48666 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751298AbdJWKpR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 06:45:17 -0400
Received: by mail-pg0-f66.google.com with SMTP id v78so11456973pgb.5
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 03:45:16 -0700 (PDT)
In-Reply-To: <15984f2370698158ef2af599b8619a2b7f64852d.1508755319.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1508755319.git.lucien.xin@gmail.com>
References: <cover.1508755319.git.lucien.xin@gmail.com>
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
