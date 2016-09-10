From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] tipc: fix possible memory leak in tipc_udp_enable()
Date: Sat, 10 Sep 2016 00:56:55 +0000
Message-ID: <1473469015-6180-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>, netdev@vger.kernel.org,
        tipc-discussion@lists.sourceforge.net
To: Jon Maloy <jon.maloy@ericsson.com>,
        Ying Xue <ying.xue@windriver.com>,
        "David S. Miller" <davem@davemloft.net>,
        Richard Alpe <richard.alpe@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34411 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751014AbcIJA5E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2016 20:57:04 -0400
Received: by mail-pf0-f193.google.com with SMTP id g202so4694937pfb.1
        for <netdev@vger.kernel.org>; Fri, 09 Sep 2016 17:57:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyongjun1@huawei.com>

'ub' is malloced in tipc_udp_enable() and should be freed before
leaving from the error handling cases, otherwise it will cause
memory leak.

Fixes: ba5aa84a2d22 ("tipc: split UDP nl address parsing")
Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
 net/tipc/udp_media.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/tipc/udp_media.c b/net/tipc/udp_media.c
index dd27468..d80cd3f 100644
--- a/net/tipc/udp_media.c
+++ b/net/tipc/udp_media.c
@@ -665,7 +665,8 @@ static int tipc_udp_enable(struct net *net, struct tipc_bearer *b,
 
 	if (!opts[TIPC_NLA_UDP_LOCAL] || !opts[TIPC_NLA_UDP_REMOTE]) {
 		pr_err("Invalid UDP bearer configuration");
-		return -EINVAL;
+		err = -EINVAL;
+		goto err;
 	}
 
 	err = tipc_parse_udp_addr(opts[TIPC_NLA_UDP_LOCAL], &local,
