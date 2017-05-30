From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH net-next] rtnetlink: use the new rtnl_get_event() interface
Date: Tue, 30 May 2017 10:07:02 -0400
Message-ID: <1496153222-13382-1-git-send-email-vyasevic@redhat.com>
Cc: dsahern@gmail.com, Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:33073 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751270AbdE3OHN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 10:07:13 -0400
Received: by mail-qt0-f195.google.com with SMTP id a46so12460287qte.0
        for <netdev@vger.kernel.org>; Tue, 30 May 2017 07:07:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Small clean-up to rtmsg_ifinfo() to use the rtnl_get_event()
interface instead of using 'internal' values directly.

Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
 net/core/rtnetlink.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 9da53e4..7084f1d 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2896,7 +2896,7 @@ static void rtmsg_ifinfo_event(int type, struct net_device *dev,
 void rtmsg_ifinfo(int type, struct net_device *dev, unsigned int change,
 		  gfp_t flags)
 {
-	rtmsg_ifinfo_event(type, dev, change, IFLA_EVENT_NONE, flags);
+	rtmsg_ifinfo_event(type, dev, change, rtnl_get_event(0), flags);
 }
 EXPORT_SYMBOL(rtmsg_ifinfo);
 
-- 
2.7.4
