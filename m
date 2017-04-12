From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next v2 4/8] rtnetlink: Do not generate notifications for POST_TYPE_CHANGE event
Date: Tue, 11 Apr 2017 17:02:43 -0700
Message-ID: <1491955367-12443-5-git-send-email-dsa@cumulusnetworks.com>
References: <1491955367-12443-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:36543 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753017AbdDLACz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 20:02:55 -0400
Received: by mail-pf0-f176.google.com with SMTP id o126so5447672pfb.3
        for <netdev@vger.kernel.org>; Tue, 11 Apr 2017 17:02:55 -0700 (PDT)
In-Reply-To: <1491955367-12443-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changing the master device for a link generates many messages; the one
generated for POST_TYPE_CHANGE is redundant:

[LINK]11: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue master br1 state UNKNOWN group default
    link/ether 02:02:02:02:02:03 brd ff:ff:ff:ff:ff:ff
[LINK]11: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue master br1 state UNKNOWN group default
    link/ether 02:02:02:02:02:03 brd ff:ff:ff:ff:ff:ff

Remove POST_TYPE_CHANGE from the list of notifiers that generate
notifications.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/core/rtnetlink.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 574f9b79919a..8cfb9e3c1f6e 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -4120,7 +4120,6 @@ static int rtnetlink_event(struct notifier_block *this, unsigned long event, voi
 	case NETDEV_CHANGENAME:
 	case NETDEV_FEAT_CHANGE:
 	case NETDEV_BONDING_FAILOVER:
-	case NETDEV_POST_TYPE_CHANGE:
 	case NETDEV_NOTIFY_PEERS:
 	case NETDEV_CHANGEUPPER:
 	case NETDEV_RESEND_IGMP:
-- 
2.1.4
