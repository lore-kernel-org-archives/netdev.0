From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 3/8] rtnetlink: Do not generate notifications for CHANGEADDR event
Date: Fri,  7 Apr 2017 14:25:35 -0700
Message-ID: <1491600340-8359-4-git-send-email-dsa@cumulusnetworks.com>
References: <1491600340-8359-1-git-send-email-dsa@cumulusnetworks.com>
Cc: vyasevic@redhat.com, davem@davemloft.net,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:34584 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754935AbdDGVZs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 17:25:48 -0400
Received: by mail-pg0-f41.google.com with SMTP id 21so77251825pgg.1
        for <netdev@vger.kernel.org>; Fri, 07 Apr 2017 14:25:48 -0700 (PDT)
In-Reply-To: <1491600340-8359-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changing hardware address generates redundant messages:

[LINK]11: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN group default event CHANGE_ADDR
    link/ether 02:02:02:02:02:02 brd ff:ff:ff:ff:ff:ff

[LINK]11: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN group default
    link/ether 02:02:02:02:02:02 brd ff:ff:ff:ff:ff:ff

Do not send a notification for the CHANGEADDR notifier.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/uapi/linux/if_link.h | 1 -
 net/core/rtnetlink.c         | 4 ----
 2 files changed, 5 deletions(-)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 064218a840b7..df5ade1bc684 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -903,7 +903,6 @@ enum {
 enum {
 	IFLA_EVENT_UNSPEC,
 	IFLA_EVENT_REBOOT,
-	IFLA_EVENT_CHANGE_ADDR,
 	IFLA_EVENT_CHANGE_NAME,
 	IFLA_EVENT_FEAT_CHANGE,
 	IFLA_EVENT_BONDING_FAILOVER,
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 1a46be074fd6..1503138ebfe1 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1285,9 +1285,6 @@ static int rtnl_fill_link_event(struct sk_buff *skb, unsigned long event)
 	case NETDEV_REBOOT:
 		rtnl_event = IFLA_EVENT_REBOOT;
 		break;
-	case NETDEV_CHANGEADDR:
-		rtnl_event = IFLA_EVENT_CHANGE_ADDR;
-		break;
 	case NETDEV_CHANGENAME:
 		rtnl_event = IFLA_EVENT_CHANGE_NAME;
 		break;
@@ -4182,7 +4179,6 @@ static int rtnetlink_event(struct notifier_block *this, unsigned long event, voi
 
 	switch (event) {
 	case NETDEV_REBOOT:
-	case NETDEV_CHANGEADDR:
 	case NETDEV_CHANGENAME:
 	case NETDEV_FEAT_CHANGE:
 	case NETDEV_BONDING_FAILOVER:
-- 
2.1.4
