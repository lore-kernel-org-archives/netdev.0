From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/18] connector: Move cn_test.c away from NLMSG_PUT().
Date: Tue, 26 Jun 2012 22:02:02 -0700 (PDT)
Message-ID: <20120626.220202.1636246120099200280.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39187 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751012Ab2F0FCD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 01:02:03 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 82AFE584190
	for <netdev@vger.kernel.org>; Tue, 26 Jun 2012 22:02:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


And use nlmsg_data() while we're here too.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 Documentation/connector/cn_test.c |   13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

diff --git a/Documentation/connector/cn_test.c b/Documentation/connector/cn_test.c
index 7764594..adcca03 100644
--- a/Documentation/connector/cn_test.c
+++ b/Documentation/connector/cn_test.c
@@ -69,9 +69,13 @@ static int cn_test_want_notify(void)
 		return -ENOMEM;
 	}
 
-	nlh = NLMSG_PUT(skb, 0, 0x123, NLMSG_DONE, size - sizeof(*nlh));
+	nlh = nlmsg_put(skb, 0, 0x123, NLMSG_DONE, size - sizeof(*nlh), 0);
+	if (!nlh) {
+		kfree_skb(skb);
+		return -EMSGSIZE;
+	}
 
-	msg = (struct cn_msg *)NLMSG_DATA(nlh);
+	msg = nlmsg_data(nlh);
 
 	memset(msg, 0, size0);
 
@@ -117,11 +121,6 @@ static int cn_test_want_notify(void)
 	pr_info("request was sent: group=0x%x\n", ctl->group);
 
 	return 0;
-
-nlmsg_failure:
-	pr_err("failed to send %u.%u\n", msg->seq, msg->ack);
-	kfree_skb(skb);
-	return -EINVAL;
 }
 #endif
 
-- 
1.7.10.2
