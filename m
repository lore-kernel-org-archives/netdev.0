From: Pan Bian <bianpan2016@163.com>
Subject: [PATCH 1/1] net: caif: remove ineffective check
Date: Sun,  4 Dec 2016 12:15:44 +0800
Message-ID: <1480824944-3439-1-git-send-email-bianpan2016@163.com>
Cc: linux-kernel@vger.kernel.org, Pan Bian <bianpan2016@163.com>
To: Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>,
        "David S. Miller" <davem@davemloft.net>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The check of the return value of sock_register() is ineffective.
"if(!err)" seems to be a typo. It is better to propagate the error code
to the callers of caif_sktinit_module(). This patch removes the check
statment and directly returns the result of sock_register().

Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=188751
Signed-off-by: Pan Bian <bianpan2016@163.com>
---
 net/caif/caif_socket.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/net/caif/caif_socket.c b/net/caif/caif_socket.c
index aa209b1..92cbbd2 100644
--- a/net/caif/caif_socket.c
+++ b/net/caif/caif_socket.c
@@ -1107,10 +1107,7 @@ static int caif_create(struct net *net, struct socket *sock, int protocol,
 
 static int __init caif_sktinit_module(void)
 {
-	int err = sock_register(&caif_family_ops);
-	if (!err)
-		return err;
-	return 0;
+	return sock_register(&caif_family_ops);
 }
 
 static void __exit caif_sktexit_module(void)
-- 
1.9.1
