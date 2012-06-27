From: David Miller <davem@davemloft.net>
Subject: [PATCH 12/18] infiniband: netlink: Move away from NLMSG_NEW().
Date: Tue, 26 Jun 2012 22:02:38 -0700 (PDT)
Message-ID: <20120626.220238.77366638451385504.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39223 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751891Ab2F0FCj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 01:02:39 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 61E01584194
	for <netdev@vger.kernel.org>; Tue, 26 Jun 2012 22:02:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


And use nlmsg_data() while we're here too.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/infiniband/core/netlink.c |   10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/infiniband/core/netlink.c b/drivers/infiniband/core/netlink.c
index e497dfb..1e691dc 100644
--- a/drivers/infiniband/core/netlink.c
+++ b/drivers/infiniband/core/netlink.c
@@ -108,12 +108,14 @@ void *ibnl_put_msg(struct sk_buff *skb, struct nlmsghdr **nlh, int seq,
 	unsigned char *prev_tail;
 
 	prev_tail = skb_tail_pointer(skb);
-	*nlh = NLMSG_NEW(skb, 0, seq, RDMA_NL_GET_TYPE(client, op),
-			len, NLM_F_MULTI);
+	*nlh = nlmsg_put(skb, 0, seq, RDMA_NL_GET_TYPE(client, op),
+			 len, NLM_F_MULTI);
+	if (!*nlh)
+		goto out_nlmsg_trim;
 	(*nlh)->nlmsg_len = skb_tail_pointer(skb) - prev_tail;
-	return NLMSG_DATA(*nlh);
+	return nlmsg_data(*nlh);
 
-nlmsg_failure:
+out_nlmsg_trim:
 	nlmsg_trim(skb, prev_tail);
 	return NULL;
 }
-- 
1.7.10.2
