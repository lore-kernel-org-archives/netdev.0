From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH net-next 3/5] sctp: if we done update ssnmap, free the new ssnmap
Date: Fri, 8 Nov 2013 10:55:08 +0800
Message-ID: <1383879310-22792-4-git-send-email-wangweidong1@huawei.com>
References: <1383879310-22792-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <dingtianhong@huawei.com>, <davem@davemloft.net>,
	<linux-sctp@vger.kernel.org>, <netdev@vger.kernel.org>
To: <vyasevich@gmail.com>, <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:32170 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756541Ab3KHCz6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 21:55:58 -0500
In-Reply-To: <1383879310-22792-1-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I found that free the old parameters after update the peer parameters.
So we should free the new ssnmap which not updated.

Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 net/sctp/associola.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index 2d53d4c..bca1ad1 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -1223,6 +1223,10 @@ void sctp_assoc_update(struct sctp_association *asoc,
 		}
 	}
 
+	/* if we don't update the ssnmap, we should free it. */
+	if (new->ssnmap)
+		sctp_ssnmap_free(new->ssnmap);
+
 	/* SCTP-AUTH: Save the peer parameters from the new assocaitions
 	 * and also move the association shared keys over
 	 */
-- 
1.7.12
