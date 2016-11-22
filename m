From: fgao@ikuai8.com
Subject: [PATCH net 1/1] driver: macvlan: Check if need rollback multicast setting in macvlan_open
Date: Tue, 22 Nov 2016 09:54:36 +0800
Message-ID: <1479779676-10417-1-git-send-email-fgao@ikuai8.com>
Cc: Gao Feng <fgao@ikuai8.com>
To: davem@davemloft.net, kaber@trash.net, netdev@vger.kernel.org,
        gfree.wind@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbg320.qq.com ([14.17.32.29]:55915 "EHLO smtpbg320.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754380AbcKVBzb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Nov 2016 20:55:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

When dev_set_promiscuity failed in macvlan_open, it always invokes
dev_set_allmulti without checking if necessary.
Now check the IFF_ALLMULTI flag firstly before rollback the multicast
setting in the error handler.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
---
 drivers/net/macvlan.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index d2d6f12..26d6f0b 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -623,7 +623,8 @@ static int macvlan_open(struct net_device *dev)
 	return 0;
 
 clear_multi:
-	dev_set_allmulti(lowerdev, -1);
+	if (dev->flags & IFF_ALLMULTI)
+		dev_set_allmulti(lowerdev, -1);
 del_unicast:
 	dev_uc_del(lowerdev, dev->dev_addr);
 out:
-- 
1.9.1
