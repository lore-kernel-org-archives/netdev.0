From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH net-next] kcm: Remove redundant unlikely()
Date: Tue, 26 Sep 2017 11:22:58 +0200
Message-ID: <20170926092258.21391-1-tklauser@distanz.ch>
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:46320 "EHLO mail.zhinst.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S968411AbdIZJXC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 26 Sep 2017 05:23:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IS_ERR() already implies unlikely(), so it can be omitted.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 net/kcm/kcmsock.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/kcm/kcmsock.c b/net/kcm/kcmsock.c
index af4e76ac88ff..0b750a22c4b9 100644
--- a/net/kcm/kcmsock.c
+++ b/net/kcm/kcmsock.c
@@ -1650,7 +1650,7 @@ static int kcm_clone(struct socket *osock, struct kcm_clone *info,
 	}
 
 	newfile = sock_alloc_file(newsock, 0, osock->sk->sk_prot_creator->name);
-	if (unlikely(IS_ERR(newfile))) {
+	if (IS_ERR(newfile)) {
 		err = PTR_ERR(newfile);
 		goto out_sock_alloc_fail;
 	}
-- 
2.13.0
