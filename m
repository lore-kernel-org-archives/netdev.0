From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH net-next 1/2] rtnetlink: Disable notification for NETDEV_NAMECHANGE event
Date: Fri, 21 Apr 2017 13:31:20 -0400
Message-ID: <1492795881-11914-2-git-send-email-vyasevic@redhat.com>
References: <1492795881-11914-1-git-send-email-vyasevic@redhat.com>
Cc: dsa@cumulusnetworks.com, Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:33226 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1422986AbdDURie (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 13:38:34 -0400
Received: by mail-qk0-f194.google.com with SMTP id o85so2030868qkh.0
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 10:38:34 -0700 (PDT)
In-Reply-To: <1492795881-11914-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The data signaling name change is already provided at
the end of do_setlink().  This event handler just generates
a duplicate announcement.  Disable it.

CC: David Ahern <dsa@cumulusnetworks.com>
Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
 net/core/rtnetlink.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 0ee5479..e8e6816 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -4123,7 +4123,6 @@ static int rtnetlink_event(struct notifier_block *this, unsigned long event, voi
 
 	switch (event) {
 	case NETDEV_REBOOT:
-	case NETDEV_CHANGENAME:
 	case NETDEV_FEAT_CHANGE:
 	case NETDEV_BONDING_FAILOVER:
 	case NETDEV_NOTIFY_PEERS:
-- 
2.7.4
