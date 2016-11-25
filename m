From: fgao@ikuai8.com
Subject: [PATCH net 1/1] driver: macvtap: Unregister netdev rx_handler if macvtap_newlink fails
Date: Fri, 25 Nov 2016 10:05:06 +0800
Message-ID: <1480039506-29740-1-git-send-email-fgao@ikuai8.com>
Cc: Gao Feng <fgao@ikuai8.com>
To: davem@davemloft.net, jasowang@redhat.com, edumazet@google.com,
        netdev@vger.kernel.org, gfree.wind@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbg291.qq.com ([113.108.11.223]:34016 "EHLO smtpbg291.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750909AbcKYCFs (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 24 Nov 2016 21:05:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

The macvtap_newlink registers the netdev rx_handler firstly, but it
does not unregister the handler if macvlan_common_newlink failed.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
---
 drivers/net/macvtap.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 070e329..bceca28 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -491,7 +491,13 @@ static int macvtap_newlink(struct net *src_net,
 	/* Don't put anything that may fail after macvlan_common_newlink
 	 * because we can't undo what it does.
 	 */
-	return macvlan_common_newlink(src_net, dev, tb, data);
+	err = macvlan_common_newlink(src_net, dev, tb, data);
+	if (err) {
+		netdev_rx_handler_unregister(dev);
+		return err;
+	}
+
+	return 0;
 }
 
 static void macvtap_dellink(struct net_device *dev,
-- 
1.9.1
