From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/18] gdm72xx: Move away from NLMSG_PUT().
Date: Tue, 26 Jun 2012 22:02:06 -0700 (PDT)
Message-ID: <20120626.220206.1076042544693422783.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39189 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751012Ab2F0FCG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 01:02:06 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 1BA8F584190
	for <netdev@vger.kernel.org>; Tue, 26 Jun 2012 22:02:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


And use nlmsg_data() while we're here too.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/staging/gdm72xx/netlink_k.c |   10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/gdm72xx/netlink_k.c b/drivers/staging/gdm72xx/netlink_k.c
index 292af0f..d0cb48a 100644
--- a/drivers/staging/gdm72xx/netlink_k.c
+++ b/drivers/staging/gdm72xx/netlink_k.c
@@ -127,8 +127,12 @@ int netlink_send(struct sock *sock, int group, u16 type, void *msg, int len)
 	}
 
 	seq++;
-	nlh = NLMSG_PUT(skb, 0, seq, type, len);
-	memcpy(NLMSG_DATA(nlh), msg, len);
+	nlh = nlmsg_put(skb, 0, seq, type, len, 0);
+	if (!nlh) {
+		kfree_skb(skb);
+		return -EMSGSIZE;
+	}
+	memcpy(nlmsg_data(nlh), msg, len);
 
 	NETLINK_CB(skb).pid = 0;
 	NETLINK_CB(skb).dst_group = 0;
@@ -144,7 +148,5 @@ int netlink_send(struct sock *sock, int group, u16 type, void *msg, int len)
 		}
 		ret = 0;
 	}
-
-nlmsg_failure:
 	return ret;
 }
-- 
1.7.10.2
