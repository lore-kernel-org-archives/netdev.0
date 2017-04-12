From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next v2 3/8] rtnetlink: Do not generate notifications for CHANGEADDR event
Date: Tue, 11 Apr 2017 17:02:42 -0700
Message-ID: <1491955367-12443-4-git-send-email-dsa@cumulusnetworks.com>
References: <1491955367-12443-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:36540 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752845AbdDLACz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 20:02:55 -0400
Received: by mail-pf0-f179.google.com with SMTP id o126so5447535pfb.3
        for <netdev@vger.kernel.org>; Tue, 11 Apr 2017 17:02:54 -0700 (PDT)
In-Reply-To: <1491955367-12443-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changing hardware address generates redundant messages:

[LINK]11: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN group default
    link/ether 02:02:02:02:02:02 brd ff:ff:ff:ff:ff:ff

[LINK]11: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN group default
    link/ether 02:02:02:02:02:02 brd ff:ff:ff:ff:ff:ff

Do not send a notification for the CHANGEADDR notifier.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/core/rtnetlink.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 58722bf10d50..574f9b79919a 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -4117,7 +4117,6 @@ static int rtnetlink_event(struct notifier_block *this, unsigned long event, voi
 
 	switch (event) {
 	case NETDEV_REBOOT:
-	case NETDEV_CHANGEADDR:
 	case NETDEV_CHANGENAME:
 	case NETDEV_FEAT_CHANGE:
 	case NETDEV_BONDING_FAILOVER:
-- 
2.1.4
