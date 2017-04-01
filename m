From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH net-next 1/2] rtnetlink: Convert rtnetlink_event to white list
Date: Fri, 31 Mar 2017 22:27:33 -0400
Message-ID: <1491013654-395-2-git-send-email-vyasevic@redhat.com>
References: <1491013654-395-1-git-send-email-vyasevic@redhat.com>
Cc: roopa@cumulusnetworks.com, dsa@cumulusnetworks.com,
        davem@davemloft.net, Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:35880 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750816AbdDAC1z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 31 Mar 2017 22:27:55 -0400
Received: by mail-qt0-f196.google.com with SMTP id n37so12453070qtb.3
        for <netdev@vger.kernel.org>; Fri, 31 Mar 2017 19:27:54 -0700 (PDT)
In-Reply-To: <1491013654-395-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The rtnetlink_event currently functions as a blacklist where
we block cerntain netdev events from being sent to user space.
As a result, events have been added to the system that userspace
probably doesn't care about.

This patch converts the implementation to the white list so that
newly events would have to be specifically added to the list to
be sent to userspace.  This would force new event implementers to
consider whether a given event is usefull to user space or if it's
just a kernel event.

Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
 net/core/rtnetlink.c | 29 +++++++++++++++--------------
 1 file changed, 15 insertions(+), 14 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 9c3947a..f48a60d 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -4116,22 +4116,23 @@ static int rtnetlink_event(struct notifier_block *this, unsigned long event, voi
 	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
 
 	switch (event) {
-	case NETDEV_UP:
-	case NETDEV_DOWN:
-	case NETDEV_PRE_UP:
-	case NETDEV_POST_INIT:
-	case NETDEV_REGISTER:
-	case NETDEV_CHANGE:
-	case NETDEV_PRE_TYPE_CHANGE:
-	case NETDEV_GOING_DOWN:
-	case NETDEV_UNREGISTER:
-	case NETDEV_UNREGISTER_FINAL:
-	case NETDEV_RELEASE:
-	case NETDEV_JOIN:
-	case NETDEV_BONDING_INFO:
+	case NETDEV_REBOOT:
+	case NETDEV_CHANGEMTU:
+	case NETDEV_CHANGENAME:
+	case NETDEV_FEAT_CHANGE:
+	case NETDEV_BONDING_FAILOVER:
+	case NETDEV_NOTIFY_PEERS:
+	case NETDEV_CHANGEUPPER:
+	case NETDEV_RESEND_IGMP:
+	case NETDEV_PRECHANGEMTU:
+	case NETDEV_CHANGEINFODATA:
+	case NETDEV_PRECHANGEUPPER:
+	case NETDEV_CHANGELOWERSTATE:
+	case NETDEV_UDP_TUNNEL_PUSH_INFO:
+	case NETDEV_CHANGE_TX_QUEUE_LEN:
+		rtmsg_ifinfo(RTM_NEWLINK, dev, 0, GFP_KERNEL);
 		break;
 	default:
-		rtmsg_ifinfo(RTM_NEWLINK, dev, 0, GFP_KERNEL);
 		break;
 	}
 	return NOTIFY_DONE;
-- 
2.7.4
