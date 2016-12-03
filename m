From: Pan Bian <bianpan2016@163.com>
Subject: [PATCH 1/1] net: caif: fix ineffective error check
Date: Sat,  3 Dec 2016 19:18:21 +0800
Message-ID: <1480763901-5323-1-git-send-email-bianpan2016@163.com>
Cc: linux-kernel@vger.kernel.org, Pan Bian <bianpan2016@163.com>
To: Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In function caif_sktinit_module(), the check of the return value of
sock_register() seems ineffective. This patch fixes it.

Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=188751

Signed-off-by: Pan Bian <bianpan2016@163.com>
---
 net/caif/caif_socket.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/caif/caif_socket.c b/net/caif/caif_socket.c
index aa209b1..2a689a3 100644
--- a/net/caif/caif_socket.c
+++ b/net/caif/caif_socket.c
@@ -1108,7 +1108,7 @@ static int caif_create(struct net *net, struct socket *sock, int protocol,
 static int __init caif_sktinit_module(void)
 {
 	int err = sock_register(&caif_family_ops);
-	if (!err)
+	if (err)
 		return err;
 	return 0;
 }
-- 
1.9.1
