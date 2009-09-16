From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: [PATCH 2/2] ieee802154: add locking for seq numbers
Date: Wed, 16 Sep 2009 17:22:13 +0400
Message-ID: <1253107333-25043-3-git-send-email-dbaryshkov@gmail.com>
References: <1253107333-25043-1-git-send-email-dbaryshkov@gmail.com>
 <1253107333-25043-2-git-send-email-dbaryshkov@gmail.com>
Cc: linux-zigbee-devel@lists.sourceforge.net,
	Sergey Lapin <slapin@ossfans.org>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f206.google.com ([209.85.219.206]:38276 "EHLO
	mail-ew0-f206.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750812AbZIPNW7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2009 09:22:59 -0400
Received: by mail-ew0-f206.google.com with SMTP id 2so1405814ewy.17
        for <netdev@vger.kernel.org>; Wed, 16 Sep 2009 06:23:02 -0700 (PDT)
In-Reply-To: <1253107333-25043-2-git-send-email-dbaryshkov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
---
 net/ieee802154/netlink.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/ieee802154/netlink.c b/net/ieee802154/netlink.c
index 2106ecb..ca767bd 100644
--- a/net/ieee802154/netlink.c
+++ b/net/ieee802154/netlink.c
@@ -35,6 +35,7 @@
 #include <net/ieee802154_netdev.h>
 
 static unsigned int ieee802154_seq_num;
+static DEFINE_SPINLOCK(ieee802154_seq_lock);
 
 static struct genl_family ieee802154_coordinator_family = {
 	.id		= GENL_ID_GENERATE,
@@ -57,12 +58,15 @@ static struct sk_buff *ieee802154_nl_create(int flags, u8 req)
 {
 	void *hdr;
 	struct sk_buff *msg = nlmsg_new(NLMSG_GOODSIZE, GFP_ATOMIC);
+	unsigned long f;
 
 	if (!msg)
 		return NULL;
 
+	spin_lock_irqsave(&ieee802154_seq_lock, f);
 	hdr = genlmsg_put(msg, 0, ieee802154_seq_num++,
 			&ieee802154_coordinator_family, flags, req);
+	spin_unlock_irqrestore(&ieee802154_seq_lock, f);
 	if (!hdr) {
 		nlmsg_free(msg);
 		return NULL;
-- 
1.6.3.3

