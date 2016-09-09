From: Javier Martinez Canillas <javier@osg.samsung.com>
Subject: [PATCH 1/8] appletalk: use IS_ENABLED() instead of checking for built-in or module
Date: Fri,  9 Sep 2016 08:43:13 -0400
Message-ID: <1473425000-9782-2-git-send-email-javier@osg.samsung.com>
References: <1473425000-9782-1-git-send-email-javier@osg.samsung.com>
Cc: Javier Martinez Canillas <javier@osg.samsung.com>,
        netdev@vger.kernel.org,
        Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
        "David S. Miller" <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1473425000-9782-1-git-send-email-javier@osg.samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The IS_ENABLED() macro checks if a Kconfig symbol has been enabled either
built-in or as a module, use that macro instead of open coding the same.

Using the macro makes the code more readable by helping abstract away some
of the Kconfig built-in and module enable details.

Signed-off-by: Javier Martinez Canillas <javier@osg.samsung.com>
---

 net/appletalk/ddp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
index f066781be3c8..10d2bdce686e 100644
--- a/net/appletalk/ddp.c
+++ b/net/appletalk/ddp.c
@@ -1278,7 +1278,7 @@ out:
 	return err;
 }
 
-#if defined(CONFIG_IPDDP) || defined(CONFIG_IPDDP_MODULE)
+#if IS_ENABLED(CONFIG_IPDDP)
 static __inline__ int is_ip_over_ddp(struct sk_buff *skb)
 {
 	return skb->data[12] == 22;
-- 
2.7.4
