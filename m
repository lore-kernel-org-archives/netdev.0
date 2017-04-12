From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next v2 2/8] rtnetlink: Do not generate notification for UDP_TUNNEL_PUSH_INFO
Date: Tue, 11 Apr 2017 17:02:41 -0700
Message-ID: <1491955367-12443-3-git-send-email-dsa@cumulusnetworks.com>
References: <1491955367-12443-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:34416 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752498AbdDLACy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 20:02:54 -0400
Received: by mail-pf0-f170.google.com with SMTP id c198so5460480pfc.1
        for <netdev@vger.kernel.org>; Tue, 11 Apr 2017 17:02:54 -0700 (PDT)
In-Reply-To: <1491955367-12443-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NETDEV_UDP_TUNNEL_PUSH_INFO is an internal notifier; nothing userspace
can do so don't generate a netlink notification.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/core/rtnetlink.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 79ab43796b08..58722bf10d50 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -4128,7 +4128,6 @@ static int rtnetlink_event(struct notifier_block *this, unsigned long event, voi
 	case NETDEV_CHANGEINFODATA:
 	case NETDEV_PRECHANGEUPPER:
 	case NETDEV_CHANGELOWERSTATE:
-	case NETDEV_UDP_TUNNEL_PUSH_INFO:
 	case NETDEV_CHANGE_TX_QUEUE_LEN:
 		rtmsg_ifinfo(RTM_NEWLINK, dev, 0, GFP_KERNEL);
 		break;
-- 
2.1.4
