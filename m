From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: [PATCH 2/3] nl802154: fix Oops in ieee802154_nl_get_dev
Date: Mon, 29 Jun 2009 19:02:14 +0400
Message-ID: <1246287735-2692-3-git-send-email-dbaryshkov@gmail.com>
References: <1246287735-2692-1-git-send-email-dbaryshkov@gmail.com>
 <1246287735-2692-2-git-send-email-dbaryshkov@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	slapin@ossfans.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f218.google.com ([209.85.220.218]:61503 "EHLO
	mail-fx0-f218.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760138AbZF2PCl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jun 2009 11:02:41 -0400
In-Reply-To: <1246287735-2692-2-git-send-email-dbaryshkov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ieee802154_nl_get_dev() lacks check for the existance of the device
that was returned by dev_get_XXX, thus resulting in Oops for non-existing
devices. Fix it.

Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
---
 net/ieee802154/netlink.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/ieee802154/netlink.c b/net/ieee802154/netlink.c
index 105ad10..332b947 100644
--- a/net/ieee802154/netlink.c
+++ b/net/ieee802154/netlink.c
@@ -276,6 +276,9 @@ static struct net_device *ieee802154_nl_get_dev(struct genl_info *info)
 	else
 		return NULL;
 
+	if (!dev)
+		return NULL;
+
 	if (dev->type != ARPHRD_IEEE802154) {
 		dev_put(dev);
 		return NULL;
-- 
1.6.3.1

