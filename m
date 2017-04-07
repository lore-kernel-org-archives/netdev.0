From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 5/8] rtnetlink: Remove NETDEV_CHANGEINFODATA netdev event
Date: Fri,  7 Apr 2017 14:25:37 -0700
Message-ID: <1491600340-8359-6-git-send-email-dsa@cumulusnetworks.com>
References: <1491600340-8359-1-git-send-email-dsa@cumulusnetworks.com>
Cc: vyasevic@redhat.com, davem@davemloft.net,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f46.google.com ([74.125.83.46]:33066 "EHLO
        mail-pg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756420AbdDGVZu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 17:25:50 -0400
Received: by mail-pg0-f46.google.com with SMTP id x125so77211356pgb.0
        for <netdev@vger.kernel.org>; Fri, 07 Apr 2017 14:25:49 -0700 (PDT)
In-Reply-To: <1491600340-8359-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nobody cares about the event, so don't send it.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 drivers/net/bonding/bond_options.c | 2 --
 include/linux/netdevice.h          | 1 -
 include/uapi/linux/if_link.h       | 1 -
 net/core/rtnetlink.c               | 4 ----
 4 files changed, 8 deletions(-)

diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index 1bcbb8913e17..533518a64496 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -673,8 +673,6 @@ int __bond_opt_set(struct bonding *bond,
 out:
 	if (ret)
 		bond_opt_error_interpret(bond, opt, ret, val);
-	else if (bond->dev->reg_state == NETREG_REGISTERED)
-		call_netdevice_notifiers(NETDEV_CHANGEINFODATA, bond->dev);
 
 	return ret;
 }
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index cc07c3be2705..bd0d26fbec2b 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2279,7 +2279,6 @@ struct netdev_lag_lower_state_info {
 #define NETDEV_CHANGEUPPER	0x0015
 #define NETDEV_RESEND_IGMP	0x0016
 #define NETDEV_PRECHANGEMTU	0x0017 /* notify before mtu change happened */
-#define NETDEV_CHANGEINFODATA	0x0018
 #define NETDEV_BONDING_INFO	0x0019
 #define NETDEV_PRECHANGEUPPER	0x001A
 #define NETDEV_CHANGELOWERSTATE	0x001B
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 80f3574a4630..a500a12d0131 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -909,7 +909,6 @@ enum {
 	IFLA_EVENT_NOTIFY_PEERS,
 	IFLA_EVENT_CHANGE_UPPER,
 	IFLA_EVENT_RESEND_IGMP,
-	IFLA_EVENT_CHANGE_INFO_DATA,
 	IFLA_EVENT_PRE_CHANGE_UPPER,
 	IFLA_EVENT_CHANGE_LOWER_STATE,
 	IFLA_EVENT_CHANGE_TX_QUEUE_LEN,
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 739b06ac3e7f..702723c5db58 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1303,9 +1303,6 @@ static int rtnl_fill_link_event(struct sk_buff *skb, unsigned long event)
 	case NETDEV_RESEND_IGMP:
 		rtnl_event = IFLA_EVENT_RESEND_IGMP;
 		break;
-	case NETDEV_CHANGEINFODATA:
-		rtnl_event = IFLA_EVENT_CHANGE_INFO_DATA;
-		break;
 	case NETDEV_PRECHANGEUPPER:
 		rtnl_event = IFLA_EVENT_PRE_CHANGE_UPPER;
 		break;
@@ -4182,7 +4179,6 @@ static int rtnetlink_event(struct notifier_block *this, unsigned long event, voi
 	case NETDEV_NOTIFY_PEERS:
 	case NETDEV_CHANGEUPPER:
 	case NETDEV_RESEND_IGMP:
-	case NETDEV_CHANGEINFODATA:
 	case NETDEV_PRECHANGEUPPER:
 	case NETDEV_CHANGELOWERSTATE:
 	case NETDEV_CHANGE_TX_QUEUE_LEN:
-- 
2.1.4
