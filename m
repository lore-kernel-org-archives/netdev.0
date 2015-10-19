From: Insu Yun <wuninsu@gmail.com>
Subject: [PATCH] nfc: free skb buffer using skb_free_datagram
Date: Mon, 19 Oct 2015 15:59:17 +0000
Message-ID: <1445270357-23785-1-git-send-email-wuninsu@gmail.com>
Cc: taesoo@gatech.edu, yeongjin.jang@gatech.edu, insu@gatech.edu,
	changwoo@gatech.edu, Insu Yun <wuninsu@gmail.com>
To: lauro.venancio@openbossa.org, aloisio.almeida@openbossa.org,
	sameo@linux.intel.com, davem@davemloft.net,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Freeing sk_buff genereated by skb_recv_datagram is always by
skb_free_datagram, not kfree_skb.

Signed-off-by: Insu Yun <wuninsu@gmail.com>
---
 net/nfc/llcp_sock.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/nfc/llcp_sock.c b/net/nfc/llcp_sock.c
index b7de0da..15e681f 100644
--- a/net/nfc/llcp_sock.c
+++ b/net/nfc/llcp_sock.c
@@ -870,7 +870,7 @@ static int llcp_sock_recvmsg(struct socket *sock, struct msghdr *msg,
 			}
 		}
 
-		kfree_skb(skb);
+		skb_free_datagram(sk, skb);
 	}
 
 	/* XXX Queue backlogged skbs */
-- 
1.9.1
