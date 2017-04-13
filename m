From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [PATCH block-tree] net: off by one in inet6_pton()
Date: Thu, 13 Apr 2017 22:42:31 +0300
Message-ID: <20170413194231.GD591@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wei Tang <tangwei@cmss.chinamobile.com>,
        Alexey Dobriyan <adobriyan@gmail.com>, netdev@vger.kernel.org,
        linux-block@vger.kernel.org, kernel-janitors@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>, Jens Axboe <axboe@fb.com>,
        Sagi Grimberg <sagi@grimberg.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:50945 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755604AbdDMTmy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Apr 2017 15:42:54 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If "scope_len" is sizeof(scope_id) then we would put the NUL terminator
one space beyond the end of the buffer.

Fixes: b1a951fe469e ("net/utils: generic inet_pton_with_scope helper")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
This one goes through Jens' tree not through net-dev.

diff --git a/net/core/utils.c b/net/core/utils.c
index da1089ea5389..93066bd0305a 100644
--- a/net/core/utils.c
+++ b/net/core/utils.c
@@ -339,7 +339,7 @@ static int inet6_pton(struct net *net, const char *src, u16 port_num,
 	    src + srclen != scope_delim && *scope_delim == '%') {
 		struct net_device *dev;
 		char scope_id[16];
-		size_t scope_len = min_t(size_t, sizeof(scope_id),
+		size_t scope_len = min_t(size_t, sizeof(scope_id) - 1,
 					 src + srclen - scope_delim - 1);
 
 		memcpy(scope_id, scope_delim + 1, scope_len);
