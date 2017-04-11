From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH net-next v2] devlink: fix return value check in devlink_dpipe_header_put()
Date: Tue, 11 Apr 2017 16:02:02 +0000
Message-ID: <20170411160202.17469-1-weiyj.lk@gmail.com>
References: <20170410131106.27683-1-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>, netdev@vger.kernel.org
To: Jiri Pirko <jiri@mellanox.com>,
        Arkadi Sharshevsky <arkadis@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35943 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751396AbdDKQCP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 12:02:15 -0400
Received: by mail-pf0-f196.google.com with SMTP id i5so226551pfc.3
        for <netdev@vger.kernel.org>; Tue, 11 Apr 2017 09:02:14 -0700 (PDT)
In-Reply-To: <20170410131106.27683-1-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyongjun1@huawei.com>

Fix the return value check which testing the wrong variable
in devlink_dpipe_header_put().

Fixes: 1555d204e743 ("devlink: Support for pipeline debug (dpipe)")
Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
Acked-by: Jiri Pirko <jiri@mellanox.com>
---
v1 -> v2: fix  a typo in patch comment
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
