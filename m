From: David Ahern <dsahern@gmail.com>
Subject: [PATCH net] Revert "rtnetlink: Do not generate notifications for CHANGEADDR event"
Date: Wed, 19 Jul 2017 10:22:40 -0700
Message-ID: <1500484960-4967-1-git-send-email-dsahern@gmail.com>
Cc: yaroslav.isakov@gmail.com, David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35102 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752257AbdGSRWq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2017 13:22:46 -0400
Received: by mail-pf0-f193.google.com with SMTP id q85so471728pfq.2
        for <netdev@vger.kernel.org>; Wed, 19 Jul 2017 10:22:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit cd8966e75ed3c6b41a37047a904617bc44fa481f.

The duplicate CHANGEADDR event message is sent regardless of link
status whereas the setlink changes only generate a notification when
the link is up. Not sending a notification when the link is down breaks
dhcpcd which only processes hwaddr changes when the link is down.

Fixes reported regression:
    https://bugzilla.kernel.org/show_bug.cgi?id=196355

Reported-by: Yaroslav Isakov <yaroslav.isakov@gmail.com>
Signed-off-by: David Ahern <dsahern@gmail.com>
---
 net/core/rtnetlink.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index d1ba90980be1..11b25fbf3dd2 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -4241,6 +4241,7 @@ static int rtnetlink_event(struct notifier_block *this, unsigned long event, voi
 
 	switch (event) {
 	case NETDEV_REBOOT:
+	case NETDEV_CHANGEADDR:
 	case NETDEV_CHANGENAME:
 	case NETDEV_FEAT_CHANGE:
 	case NETDEV_BONDING_FAILOVER:
-- 
2.1.4
