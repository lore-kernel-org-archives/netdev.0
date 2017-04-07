From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 2/8] rtnetlink: Do not generate notification for UDP_TUNNEL_PUSH_INFO
Date: Fri,  7 Apr 2017 14:25:34 -0700
Message-ID: <1491600340-8359-3-git-send-email-dsa@cumulusnetworks.com>
References: <1491600340-8359-1-git-send-email-dsa@cumulusnetworks.com>
Cc: vyasevic@redhat.com, davem@davemloft.net,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:36787 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933390AbdDGVZw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 17:25:52 -0400
Received: by mail-pg0-f45.google.com with SMTP id g2so76021174pge.3
        for <netdev@vger.kernel.org>; Fri, 07 Apr 2017 14:25:52 -0700 (PDT)
In-Reply-To: <1491600340-8359-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NETDEV_UDP_TUNNEL_PUSH_INFO is an internal notifier; nothing userspace
can do so don't generate a netlink notification.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/uapi/linux/if_link.h | 1 -
 net/core/rtnetlink.c         | 4 ----
 2 files changed, 5 deletions(-)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index e8b7e9342cc0..064218a840b7 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -914,7 +914,6 @@ enum {
 	IFLA_EVENT_CHANGE_INFO_DATA,
 	IFLA_EVENT_PRE_CHANGE_UPPER,
 	IFLA_EVENT_CHANGE_LOWER_STATE,
-	IFLA_EVENT_UDP_TUNNEL_PUSH_INFO,
 	IFLA_EVENT_CHANGE_TX_QUEUE_LEN,
 };
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 72d365ae14b3..1a46be074fd6 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1318,9 +1318,6 @@ static int rtnl_fill_link_event(struct sk_buff *skb, unsigned long event)
 	case NETDEV_CHANGELOWERSTATE:
 		rtnl_event = IFLA_EVENT_CHANGE_LOWER_STATE;
 		break;
-	case NETDEV_UDP_TUNNEL_PUSH_INFO:
-		rtnl_event = IFLA_EVENT_UDP_TUNNEL_PUSH_INFO;
-		break;
 	case NETDEV_CHANGE_TX_QUEUE_LEN:
 		rtnl_event = IFLA_EVENT_CHANGE_TX_QUEUE_LEN;
 		break;
@@ -4196,7 +4193,6 @@ static int rtnetlink_event(struct notifier_block *this, unsigned long event, voi
 	case NETDEV_CHANGEINFODATA:
 	case NETDEV_PRECHANGEUPPER:
 	case NETDEV_CHANGELOWERSTATE:
-	case NETDEV_UDP_TUNNEL_PUSH_INFO:
 	case NETDEV_CHANGE_TX_QUEUE_LEN:
 		rtmsg_ifinfo_event(RTM_NEWLINK, dev, 0, event, GFP_KERNEL);
 		break;
-- 
2.1.4
