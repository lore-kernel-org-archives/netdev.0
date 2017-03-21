From: fgao@ikuai8.com
Subject: [PATCH net v3 1/1] net: tcp: Permit user set TCP_MAXSEG to default value
Date: Tue, 21 Mar 2017 09:28:03 +0800
Message-ID: <1490059683-13884-1-git-send-email-fgao@ikuai8.com>
Cc: Gao Feng <fgao@ikuai8.com>
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        eric.dumazet@gmail.com, netdev@vger.kernel.org,
        gfree.wind@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbg291.qq.com ([113.108.11.223]:33847 "EHLO smtpbg291.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754583AbdCUB3E (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 20 Mar 2017 21:29:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

When user_mss is zero, it means use the default value. But the current
codes don't permit user set TCP_MAXSEG to the default value.
It would return the -EINVAL when val is zero.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
---
 v3: Correct the logic error, per Neal
 v2: Make codes more clearer, per Eric
 v1: initial version

 net/ipv4/tcp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 1e319a5..4f7f163 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2470,7 +2470,7 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 		/* Values greater than interface MTU won't take effect. However
 		 * at the point when this call is done we typically don't yet
 		 * know which interface is going to be used */
-		if (val < TCP_MIN_MSS || val > MAX_TCP_WINDOW) {
+		if (val && (val < TCP_MIN_MSS || val > MAX_TCP_WINDOW)) {
 			err = -EINVAL;
 			break;
 		}
-- 
1.9.1
