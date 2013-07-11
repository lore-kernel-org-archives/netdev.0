From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH 2/2] ifb: fix oops when loading the ifb failed
Date: Thu, 11 Jul 2013 19:04:06 +0800
Message-ID: <51DE9126.5040703@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <edumazet@google.com>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:26377 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755031Ab3GKLE2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 07:04:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If __rtnl_link_register() return faild when loading the ifb, it will
take the wrong path and get oops, so fix it just like dummy.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/ifb.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index dc9f6a4..23a33e3 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -291,11 +291,15 @@ static int __init ifb_init_module(void)
 
 	rtnl_lock();
 	err = __rtnl_link_register(&ifb_link_ops);
+	if (err < 0)
+		goto out;
 
 	for (i = 0; i < numifbs && !err; i++)
 		err = ifb_init_one(i);
 	if (err)
 		__rtnl_link_unregister(&ifb_link_ops);
+
+out:
 	rtnl_unlock();
 
 	return err;
-- 
1.8.0
