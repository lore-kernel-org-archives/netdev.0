From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: [PATCH 03/17] wpan-phy: init channel/page fields
Date: Fri,  6 Nov 2009 15:39:27 +0300
Message-ID: <1257511181-19403-4-git-send-email-dbaryshkov@gmail.com>
References: <1257511181-19403-1-git-send-email-dbaryshkov@gmail.com>
Cc: netdev@vger.kernel.org, Sergey Lapin <slapin@ossfans.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f207.google.com ([209.85.219.207]:58044 "EHLO
	mail-ew0-f207.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757632AbZKFMkl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 07:40:41 -0500
Received: by mail-ew0-f207.google.com with SMTP id 3so975605ewy.37
        for <netdev@vger.kernel.org>; Fri, 06 Nov 2009 04:40:46 -0800 (PST)
In-Reply-To: <1257511181-19403-1-git-send-email-dbaryshkov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Set page to zero (for compatibility w/ devices supporting only first page).
Also init channel by default to -1 to disallow transfers for non-initialised
devices.

Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
---
 net/ieee802154/wpan-class.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/ieee802154/wpan-class.c b/net/ieee802154/wpan-class.c
index 0cec138..a10ae5b 100644
--- a/net/ieee802154/wpan-class.c
+++ b/net/ieee802154/wpan-class.c
@@ -143,6 +143,9 @@ struct wpan_phy *wpan_phy_alloc(size_t priv_size)
 
 	phy->dev.class = &wpan_phy_class;
 
+	phy->current_channel = -1; /* not initialised */
+	phy->current_page = 0; /* for compatibility */
+
 	return phy;
 }
 EXPORT_SYMBOL(wpan_phy_alloc);
-- 
1.6.5

