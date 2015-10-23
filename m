From: LABBE Corentin <clabbe.montjoie@gmail.com>
Subject: [PATCH 03/11] net: llc: change copied to size_t in llc_ui_sendmsg
Date: Fri, 23 Oct 2015 14:10:28 +0200
Message-ID: <1445602236-24130-4-git-send-email-clabbe.montjoie@gmail.com>
References: <1445602236-24130-1-git-send-email-clabbe.montjoie@gmail.com>
Cc: LABBE Corentin <clabbe.montjoie@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: acme@ghostprotocols.net, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445602236-24130-1-git-send-email-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The variable copied in llc_ui_sendmsg() cannot be negative and is used
in functions that wait for unsigned value, so set it as size_t (like it
is in llc_ui_recvmsg())

Signed-off-by: LABBE Corentin <clabbe.montjoie@gmail.com>
---
 net/llc/af_llc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/llc/af_llc.c b/net/llc/af_llc.c
index 79b915d..f435b77 100644
--- a/net/llc/af_llc.c
+++ b/net/llc/af_llc.c
@@ -891,7 +891,8 @@ static int llc_ui_sendmsg(struct socket *sock, struct msghdr *msg, size_t len)
 	int noblock = flags & MSG_DONTWAIT;
 	struct sk_buff *skb;
 	size_t size = 0;
-	int rc = -EINVAL, copied = 0, hdrlen;
+	int rc = -EINVAL, hdrlen;
+	size_t copied = 0;
 
 	dprintk("%s: sending from %02X to %02X\n", __func__,
 		llc->laddr.lsap, llc->daddr.lsap);
-- 
2.4.10
