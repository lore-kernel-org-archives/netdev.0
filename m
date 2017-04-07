From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 8/8] rtnetlink: Do not generate notifications for CHANGELOWERSTATE event
Date: Fri,  7 Apr 2017 14:25:40 -0700
Message-ID: <1491600340-8359-9-git-send-email-dsa@cumulusnetworks.com>
References: <1491600340-8359-1-git-send-email-dsa@cumulusnetworks.com>
Cc: vyasevic@redhat.com, davem@davemloft.net,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f47.google.com ([74.125.83.47]:36811 "EHLO
        mail-pg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754935AbdDGVZ5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 17:25:57 -0400
Received: by mail-pg0-f47.google.com with SMTP id g2so76022414pge.3
        for <netdev@vger.kernel.org>; Fri, 07 Apr 2017 14:25:52 -0700 (PDT)
In-Reply-To: <1491600340-8359-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CHANGELOWERSTATE is an internal event; do not generate userspace
notifications.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/uapi/linux/if_link.h | 1 -
 net/core/rtnetlink.c         | 4 ----
 2 files changed, 5 deletions(-)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 8f23e9dde667..37e19966fbf3 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -908,7 +908,6 @@ enum {
 	IFLA_EVENT_BONDING_FAILOVER,
 	IFLA_EVENT_CHANGE_UPPER,
 	IFLA_EVENT_RESEND_IGMP,
-	IFLA_EVENT_CHANGE_LOWER_STATE,
 	IFLA_EVENT_CHANGE_TX_QUEUE_LEN,
 };
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index d2587aa339c4..21c03861aaf3 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1300,9 +1300,6 @@ static int rtnl_fill_link_event(struct sk_buff *skb, unsigned long event)
 	case NETDEV_RESEND_IGMP:
 		rtnl_event = IFLA_EVENT_RESEND_IGMP;
 		break;
-	case NETDEV_CHANGELOWERSTATE:
-		rtnl_event = IFLA_EVENT_CHANGE_LOWER_STATE;
-		break;
 	case NETDEV_CHANGE_TX_QUEUE_LEN:
 		rtnl_event = IFLA_EVENT_CHANGE_TX_QUEUE_LEN;
 		break;
@@ -4172,7 +4169,6 @@ static int rtnetlink_event(struct notifier_block *this, unsigned long event, voi
 	case NETDEV_BONDING_FAILOVER:
 	case NETDEV_CHANGEUPPER:
 	case NETDEV_RESEND_IGMP:
-	case NETDEV_CHANGELOWERSTATE:
 	case NETDEV_CHANGE_TX_QUEUE_LEN:
 		rtmsg_ifinfo_event(RTM_NEWLINK, dev, 0, event, GFP_KERNEL);
 		break;
-- 
2.1.4
