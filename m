From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH net-next] devlink: fix return value check in devlink_dpipe_header_put()
Date: Mon, 10 Apr 2017 13:11:06 +0000
Message-ID: <20170410131106.27683-1-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>, netdev@vger.kernel.org
To: Jiri Pirko <jiri@mellanox.com>,
        Arkadi Sharshevsky <arkadis@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:34136 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753310AbdDJNLN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Apr 2017 09:11:13 -0400
Received: by mail-pg0-f67.google.com with SMTP id o123so25691340pga.1
        for <netdev@vger.kernel.org>; Mon, 10 Apr 2017 06:11:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyongjun1@huawei.com>

Fix the retrn value check which testing the wrong variable
in devlink_dpipe_header_put().

Fixes: 1555d204e743 ("devlink: Support for pipeline debug (dpipe)")
Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
 net/core/devlink.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/devlink.c b/net/core/devlink.c
index 24b7660..0afac58 100644
--- a/net/core/devlink.c
+++ b/net/core/devlink.c
@@ -2031,7 +2031,7 @@ static int devlink_dpipe_header_put(struct sk_buff *skb,
 	int err;
 
 	header_attr = nla_nest_start(skb, DEVLINK_ATTR_DPIPE_HEADER);
-	if (!header)
+	if (!header_attr)
 		return -EMSGSIZE;
 
 	if (nla_put_string(skb, DEVLINK_ATTR_DPIPE_HEADER_NAME, header->name) ||
