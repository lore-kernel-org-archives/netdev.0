From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next] rtnetlink: Remove NETDEV_CHANGEINFODATA
Date: Fri, 28 Apr 2017 11:06:25 -0700
Message-ID: <1493402785-18844-1-git-send-email-dsa@cumulusnetworks.com>
Cc: jiri@resnulli.us, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f47.google.com ([74.125.83.47]:34919 "EHLO
        mail-pg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S642262AbdD1SGf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 14:06:35 -0400
Received: by mail-pg0-f47.google.com with SMTP id o3so13153319pgn.2
        for <netdev@vger.kernel.org>; Fri, 28 Apr 2017 11:06:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NETDEV_CHANGEINFODATA was added by d4261e5650004 ("bonding: create
netlink event when bonding option is changed"). RTM_NEWLINK
messages are already created on changelink events, so this event
is just a duplicate. Remove it.

Cc: Jiri Pirko <jiri@resnulli.us>
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 drivers/net/bonding/bond_options.c |  2 --
 include/linux/netdevice.h          | 11 +++++------
 net/core/rtnetlink.c               |  1 -
 3 files changed, 5 insertions(+), 9 deletions(-)

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
index cc07c3be2705..c49a7a901710 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2279,12 +2279,11 @@ struct netdev_lag_lower_state_info {
 #define NETDEV_CHANGEUPPER	0x0015
 #define NETDEV_RESEND_IGMP	0x0016
 #define NETDEV_PRECHANGEMTU	0x0017 /* notify before mtu change happened */
-#define NETDEV_CHANGEINFODATA	0x0018
-#define NETDEV_BONDING_INFO	0x0019
-#define NETDEV_PRECHANGEUPPER	0x001A
-#define NETDEV_CHANGELOWERSTATE	0x001B
-#define NETDEV_UDP_TUNNEL_PUSH_INFO	0x001C
-#define NETDEV_CHANGE_TX_QUEUE_LEN	0x001E
+#define NETDEV_BONDING_INFO	0x0018
+#define NETDEV_PRECHANGEUPPER	0x0019
+#define NETDEV_CHANGELOWERSTATE	0x001A
+#define NETDEV_UDP_TUNNEL_PUSH_INFO	0x001B
+#define NETDEV_CHANGE_TX_QUEUE_LEN	0x001C
 
 int register_netdevice_notifier(struct notifier_block *nb);
 int unregister_netdevice_notifier(struct notifier_block *nb);
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 58419da7961b..1072b88e5845 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -4127,7 +4127,6 @@ static int rtnetlink_event(struct notifier_block *this, unsigned long event, voi
 	case NETDEV_CHANGEUPPER:
 	case NETDEV_RESEND_IGMP:
 	case NETDEV_PRECHANGEMTU:
-	case NETDEV_CHANGEINFODATA:
 	case NETDEV_PRECHANGEUPPER:
 	case NETDEV_CHANGELOWERSTATE:
 	case NETDEV_UDP_TUNNEL_PUSH_INFO:
-- 
2.1.4
