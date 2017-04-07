From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 4/8] rtnetlink: Do not generate notifications for POST_TYPE_CHANGE event
Date: Fri,  7 Apr 2017 14:25:36 -0700
Message-ID: <1491600340-8359-5-git-send-email-dsa@cumulusnetworks.com>
References: <1491600340-8359-1-git-send-email-dsa@cumulusnetworks.com>
Cc: vyasevic@redhat.com, davem@davemloft.net,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:35257 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933491AbdDGV0E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 17:26:04 -0400
Received: by mail-pg0-f42.google.com with SMTP id 81so77184755pgh.2
        for <netdev@vger.kernel.org>; Fri, 07 Apr 2017 14:25:54 -0700 (PDT)
In-Reply-To: <1491600340-8359-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changing the master device for a link generates many messages; the one
generated for POST_TYPE_CHANGE is redundant:

[LINK]11: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue master br1 state UNKNOWN group default event POST_TYPE_CHANGE
    link/ether 02:02:02:02:02:03 brd ff:ff:ff:ff:ff:ff
[LINK]11: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue master br1 state UNKNOWN group default
    link/ether 02:02:02:02:02:03 brd ff:ff:ff:ff:ff:ff

Remove POST_TYPE_CHANGE from the list of notifiers that generate
notifications.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/uapi/linux/if_link.h | 1 -
 net/core/rtnetlink.c         | 4 ----
 2 files changed, 5 deletions(-)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index df5ade1bc684..80f3574a4630 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -906,7 +906,6 @@ enum {
 	IFLA_EVENT_CHANGE_NAME,
 	IFLA_EVENT_FEAT_CHANGE,
 	IFLA_EVENT_BONDING_FAILOVER,
-	IFLA_EVENT_POST_TYPE_CHANGE,
 	IFLA_EVENT_NOTIFY_PEERS,
 	IFLA_EVENT_CHANGE_UPPER,
 	IFLA_EVENT_RESEND_IGMP,
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 1503138ebfe1..739b06ac3e7f 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1294,9 +1294,6 @@ static int rtnl_fill_link_event(struct sk_buff *skb, unsigned long event)
 	case NETDEV_BONDING_FAILOVER:
 		rtnl_event = IFLA_EVENT_BONDING_FAILOVER;
 		break;
-	case NETDEV_POST_TYPE_CHANGE:
-		rtnl_event = IFLA_EVENT_POST_TYPE_CHANGE;
-		break;
 	case NETDEV_NOTIFY_PEERS:
 		rtnl_event = IFLA_EVENT_NOTIFY_PEERS;
 		break;
@@ -4182,7 +4179,6 @@ static int rtnetlink_event(struct notifier_block *this, unsigned long event, voi
 	case NETDEV_CHANGENAME:
 	case NETDEV_FEAT_CHANGE:
 	case NETDEV_BONDING_FAILOVER:
-	case NETDEV_POST_TYPE_CHANGE:
 	case NETDEV_NOTIFY_PEERS:
 	case NETDEV_CHANGEUPPER:
 	case NETDEV_RESEND_IGMP:
-- 
2.1.4
