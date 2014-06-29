From: Alexander Aring <alex.aring@gmail.com>
Subject: [PATCH net] ieee802154: reassembly: fix possible buffer overflow
Date: Sun, 29 Jun 2014 13:10:18 +0200
Message-ID: <1404040218-31122-1-git-send-email-alex.aring@gmail.com>
Cc: dbaryshkov@gmail.com, linux-zigbee-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, Alexander Aring <alex.aring@gmail.com>
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f179.google.com ([74.125.82.179]:53475 "EHLO
	mail-we0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752813AbaF2LKc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jun 2014 07:10:32 -0400
Received: by mail-we0-f179.google.com with SMTP id w62so7021041wes.38
        for <netdev@vger.kernel.org>; Sun, 29 Jun 2014 04:10:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The max_dsize attribute in ctl_table for lowpan_frags_ns_ctl_table is
configured with integer accessing methods. This patch change the
max_dsize attribute to int to avoid a possible buffer overflow.

Signed-off-by: Alexander Aring <alex.aring@gmail.com>
---
 include/net/netns/ieee802154_6lowpan.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/netns/ieee802154_6lowpan.h b/include/net/netns/ieee802154_6lowpan.h
index 079030c..e207096 100644
--- a/include/net/netns/ieee802154_6lowpan.h
+++ b/include/net/netns/ieee802154_6lowpan.h
@@ -16,7 +16,7 @@ struct netns_sysctl_lowpan {
 struct netns_ieee802154_lowpan {
 	struct netns_sysctl_lowpan sysctl;
 	struct netns_frags	frags;
-	u16			max_dsize;
+	int			max_dsize;
 };
 
 #endif
-- 
2.0.1
