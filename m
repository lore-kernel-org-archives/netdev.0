From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: [PATCH 04/17] wpan-phy: use snprintf to limit the amount of chars written
Date: Fri,  6 Nov 2009 15:39:28 +0300
Message-ID: <1257511181-19403-5-git-send-email-dbaryshkov@gmail.com>
References: <1257511181-19403-1-git-send-email-dbaryshkov@gmail.com>
Cc: netdev@vger.kernel.org, Sergey Lapin <slapin@ossfans.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f207.google.com ([209.85.219.207]:58044 "EHLO
	mail-ew0-f207.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757951AbZKFMkm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 07:40:42 -0500
Received: by mail-ew0-f207.google.com with SMTP id 3so975605ewy.37
        for <netdev@vger.kernel.org>; Fri, 06 Nov 2009 04:40:47 -0800 (PST)
In-Reply-To: <1257511181-19403-1-git-send-email-dbaryshkov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use snprintf to limit the amount of chars put in the buffer for attr -> show.

Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
---
 net/ieee802154/wpan-class.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ieee802154/wpan-class.c b/net/ieee802154/wpan-class.c
index a10ae5b..68ccde6 100644
--- a/net/ieee802154/wpan-class.c
+++ b/net/ieee802154/wpan-class.c
@@ -30,7 +30,7 @@ static ssize_t name ## _show(struct device *dev,			\
 	int ret;							\
 									\
 	mutex_lock(&phy->pib_lock);					\
-	ret = sprintf(buf, format_string "\n", args);			\
+	ret = snprintf(buf, PAGE_SIZE, format_string "\n", args);	\
 	mutex_unlock(&phy->pib_lock);					\
 	return ret;							\
 }
-- 
1.6.5

