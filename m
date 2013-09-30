From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH 3/4] connector: use 'size' everywhere in cn_netlink_send()
Date: Mon, 30 Sep 2013 22:03:08 +0200
Message-ID: <1380571389-15343-4-git-send-email-minipli@googlemail.com>
References: <1380571389-15343-1-git-send-email-minipli@googlemail.com>
Cc: Mathias Krause <minipli@googlemail.com>, netdev@vger.kernel.org
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f51.google.com ([209.85.214.51]:37905 "EHLO
	mail-bk0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756411Ab3I3UD2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Sep 2013 16:03:28 -0400
Received: by mail-bk0-f51.google.com with SMTP id mx10so2234293bkb.24
        for <netdev@vger.kernel.org>; Mon, 30 Sep 2013 13:03:27 -0700 (PDT)
In-Reply-To: <1380571389-15343-1-git-send-email-minipli@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We calculated the size for the netlink message buffer as size. Use size
in the memcpy() call as well instead of recalculating it.

Signed-off-by: Mathias Krause <minipli@googlemail.com>
---
 drivers/connector/connector.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/connector/connector.c b/drivers/connector/connector.c
index 0daa11e..a36749f 100644
--- a/drivers/connector/connector.c
+++ b/drivers/connector/connector.c
@@ -109,7 +109,7 @@ int cn_netlink_send(struct cn_msg *msg, u32 __group, gfp_t gfp_mask)
 
 	data = nlmsg_data(nlh);
 
-	memcpy(data, msg, sizeof(*data) + msg->len);
+	memcpy(data, msg, size);
 
 	NETLINK_CB(skb).dst_group = group;
 
-- 
1.7.10.4
