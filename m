From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net 2/6] rtnetlink: bring NETDEV_CHANGE_TX_QUEUE_LEN event process back in rtnetlink_event
Date: Sun, 15 Oct 2017 18:13:42 +0800
Message-ID: <e240a6572c8e495eb2da15bd6178604cdfde08ba.1508062280.git.lucien.xin@gmail.com>
References: <cover.1508062280.git.lucien.xin@gmail.com>
 <d7713874f0ad1c19b640eaae98f0d554d1743a4c.1508062280.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net, David Ahern <dsahern@gmail.com>,
        hannes@stressinduktion.org
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:51091 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751287AbdJOKOL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 15 Oct 2017 06:14:11 -0400
Received: by mail-pg0-f67.google.com with SMTP id y7so4552297pgb.7
        for <netdev@vger.kernel.org>; Sun, 15 Oct 2017 03:14:10 -0700 (PDT)
In-Reply-To: <d7713874f0ad1c19b640eaae98f0d554d1743a4c.1508062280.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1508062280.git.lucien.xin@gmail.com>
References: <cover.1508062280.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The same fix for changing mtu in the patch 'rtnetlink: bring
NETDEV_CHANGEMTU event process back in rtnetlink_event' is
needed for changing tx_queue_len.

Note that the redundant notifications issue for tx_queue_len
will be fixed in the later patch 'rtnetlink: do not send
notification for tx_queue_len in do_setlink'.

Fixes: 27b3b551d8a7 ("rtnetlink: Do not generate notifications for NETDEV_CHANGE_TX_QUEUE_LEN event")
Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/core/rtnetlink.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 72053ed..bf47360 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -4287,6 +4287,7 @@ static int rtnetlink_event(struct notifier_block *this, unsigned long event, voi
 	case NETDEV_NOTIFY_PEERS:
 	case NETDEV_RESEND_IGMP:
 	case NETDEV_CHANGEINFODATA:
+	case NETDEV_CHANGE_TX_QUEUE_LEN:
 		rtmsg_ifinfo_event(RTM_NEWLINK, dev, 0, rtnl_get_event(event),
 				   GFP_KERNEL);
 		break;
-- 
2.1.0
