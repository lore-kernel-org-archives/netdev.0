From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next v2 8/8] rtnetlink: Do not generate notifications for NETDEV_CHANGE_TX_QUEUE_LEN event
Date: Tue, 11 Apr 2017 17:02:47 -0700
Message-ID: <1491955367-12443-9-git-send-email-dsa@cumulusnetworks.com>
References: <1491955367-12443-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:34500 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753321AbdDLAC7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 20:02:59 -0400
Received: by mail-pg0-f42.google.com with SMTP id 21so5885064pgg.1
        for <netdev@vger.kernel.org>; Tue, 11 Apr 2017 17:02:58 -0700 (PDT)
In-Reply-To: <1491955367-12443-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changing tx queue length generates identical messages:

[LINK]22: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN group default
    link/ether 02:04:f4:b7:5c:d2 brd ff:ff:ff:ff:ff:ff promiscuity 0
    dummy numtxqueues 1 numrxqueues 1 gso_max_size 65536 gso_max_segs 65535
[LINK]22: dummy1: <BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN group default
    link/ether 02:04:f4:b7:5c:d2 brd ff:ff:ff:ff:ff:ff promiscuity 0
    dummy numtxqueues 1 numrxqueues 1 gso_max_size 65536 gso_max_segs 65535

Remove NETDEV_CHANGE_TX_QUEUE_LEN from the list of notifiers that generate
notifications.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/core/rtnetlink.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index ef93f6c983f3..c138b6b75e59 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -4123,7 +4123,6 @@ static int rtnetlink_event(struct notifier_block *this, unsigned long event, voi
 	case NETDEV_NOTIFY_PEERS:
 	case NETDEV_RESEND_IGMP:
 	case NETDEV_CHANGEINFODATA:
-	case NETDEV_CHANGE_TX_QUEUE_LEN:
 		rtmsg_ifinfo(RTM_NEWLINK, dev, 0, GFP_KERNEL);
 		break;
 	default:
-- 
2.1.4
