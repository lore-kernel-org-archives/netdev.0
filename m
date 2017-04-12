From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next v2 1/8] rtnetlink: Do not generate notifications for MTU events
Date: Tue, 11 Apr 2017 17:02:40 -0700
Message-ID: <1491955367-12443-2-git-send-email-dsa@cumulusnetworks.com>
References: <1491955367-12443-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:34413 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752603AbdDLACx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 20:02:53 -0400
Received: by mail-pf0-f179.google.com with SMTP id c198so5460358pfc.1
        for <netdev@vger.kernel.org>; Tue, 11 Apr 2017 17:02:53 -0700 (PDT)
In-Reply-To: <1491955367-12443-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changing MTU on a link currently causes 3 messages to be sent to userspace:

[LINK]11: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1490 qdisc noqueue state UNKNOWN group default
    link/ether f2:52:5c:6d:21:f3 brd ff:ff:ff:ff:ff:ff

[LINK]11: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN group default
    link/ether f2:52:5c:6d:21:f3 brd ff:ff:ff:ff:ff:ff

[LINK]11: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN group default
    link/ether f2:52:5c:6d:21:f3 brd ff:ff:ff:ff:ff:ff

Remove the messages sent for PRE_CHANGE_MTU and CHANGE_MTU netdev events.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/core/rtnetlink.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 58419da7961b..79ab43796b08 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -4117,7 +4117,6 @@ static int rtnetlink_event(struct notifier_block *this, unsigned long event, voi
 
 	switch (event) {
 	case NETDEV_REBOOT:
-	case NETDEV_CHANGEMTU:
 	case NETDEV_CHANGEADDR:
 	case NETDEV_CHANGENAME:
 	case NETDEV_FEAT_CHANGE:
@@ -4126,7 +4125,6 @@ static int rtnetlink_event(struct notifier_block *this, unsigned long event, voi
 	case NETDEV_NOTIFY_PEERS:
 	case NETDEV_CHANGEUPPER:
 	case NETDEV_RESEND_IGMP:
-	case NETDEV_PRECHANGEMTU:
 	case NETDEV_CHANGEINFODATA:
 	case NETDEV_PRECHANGEUPPER:
 	case NETDEV_CHANGELOWERSTATE:
-- 
2.1.4
