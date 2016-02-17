From: Anton Protopopov <a.s.protopopov@gmail.com>
Subject: [PATCH] appletalk: fix erroneous return value
Date: Wed, 17 Feb 2016 10:53:59 -0500
Message-ID: <1455724439-10018-1-git-send-email-a.s.protopopov@gmail.com>
Cc: Anton Protopopov <a.s.protopopov@gmail.com>
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The atalk_sendmsg() function might return wrong value ENETUNREACH
instead of -ENETUNREACH.

Signed-off-by: Anton Protopopov <a.s.protopopov@gmail.com>
---
 net/appletalk/ddp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
index d5871ac..f066781 100644
--- a/net/appletalk/ddp.c
+++ b/net/appletalk/ddp.c
@@ -1625,7 +1625,7 @@ static int atalk_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
 
 		rt = atrtr_find(&at_hint);
 	}
-	err = ENETUNREACH;
+	err = -ENETUNREACH;
 	if (!rt)
 		goto out;
 
-- 
2.6.5
