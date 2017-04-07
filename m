From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 6/8] rtnetlink: Do not generate notifications for PRECHANGEUPPER event
Date: Fri,  7 Apr 2017 14:25:38 -0700
Message-ID: <1491600340-8359-7-git-send-email-dsa@cumulusnetworks.com>
References: <1491600340-8359-1-git-send-email-dsa@cumulusnetworks.com>
Cc: vyasevic@redhat.com, davem@davemloft.net,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f47.google.com ([74.125.83.47]:34597 "EHLO
        mail-pg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933491AbdDGVZv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 17:25:51 -0400
Received: by mail-pg0-f47.google.com with SMTP id 21so77252489pgg.1
        for <netdev@vger.kernel.org>; Fri, 07 Apr 2017 14:25:51 -0700 (PDT)
In-Reply-To: <1491600340-8359-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PRECHANGEUPPER is an internal event; do not generate userspace
notifications.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/uapi/linux/if_link.h | 1 -
 net/core/rtnetlink.c         | 4 ----
 2 files changed, 5 deletions(-)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index a500a12d0131..4fa3bf3eb21d 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -909,7 +909,6 @@ enum {
 	IFLA_EVENT_NOTIFY_PEERS,
 	IFLA_EVENT_CHANGE_UPPER,
 	IFLA_EVENT_RESEND_IGMP,
-	IFLA_EVENT_PRE_CHANGE_UPPER,
 	IFLA_EVENT_CHANGE_LOWER_STATE,
 	IFLA_EVENT_CHANGE_TX_QUEUE_LEN,
 };
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 702723c5db58..e2b0ec5174e7 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1303,9 +1303,6 @@ static int rtnl_fill_link_event(struct sk_buff *skb, unsigned long event)
 	case NETDEV_RESEND_IGMP:
 		rtnl_event = IFLA_EVENT_RESEND_IGMP;
 		break;
-	case NETDEV_PRECHANGEUPPER:
-		rtnl_event = IFLA_EVENT_PRE_CHANGE_UPPER;
-		break;
 	case NETDEV_CHANGELOWERSTATE:
 		rtnl_event = IFLA_EVENT_CHANGE_LOWER_STATE;
 		break;
@@ -4179,7 +4176,6 @@ static int rtnetlink_event(struct notifier_block *this, unsigned long event, voi
 	case NETDEV_NOTIFY_PEERS:
 	case NETDEV_CHANGEUPPER:
 	case NETDEV_RESEND_IGMP:
-	case NETDEV_PRECHANGEUPPER:
 	case NETDEV_CHANGELOWERSTATE:
 	case NETDEV_CHANGE_TX_QUEUE_LEN:
 		rtmsg_ifinfo_event(RTM_NEWLINK, dev, 0, event, GFP_KERNEL);
-- 
2.1.4
