From: fgao@ikuai8.com
Subject: [PATCH net 1/1] net: tcp: Permit user set TCP_MAXSEG to default value
Date: Tue, 21 Mar 2017 05:30:17 +0800
Message-ID: <1490045417-32412-1-git-send-email-fgao@ikuai8.com>
Cc: Gao Feng <fgao@ikuai8.com>
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        netdev@vger.kernel.org, gfree.wind@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbg291.qq.com ([113.108.11.223]:43787 "EHLO smtpbg291.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755919AbdCTVbd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 20 Mar 2017 17:31:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

When user_mss is zero, it means use the default value. But the current
codes don't permit user set TCP_MAXSEG to the default value.
It would return the -EINVAL when val is zero.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
---
 net/ipv4/tcp.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 1e319a5..dd5e8e2 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2470,7 +2470,8 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 		/* Values greater than interface MTU won't take effect. However
 		 * at the point when this call is done we typically don't yet
 		 * know which interface is going to be used */
-		if (val < TCP_MIN_MSS || val > MAX_TCP_WINDOW) {
+		if (val < 0 || (val > 0 && val < TCP_MIN_MSS) ||
+		    val > MAX_TCP_WINDOW) {
 			err = -EINVAL;
 			break;
 		}
-- 
1.9.1
