From: Colin King <colin.king@canonical.com>
Subject: [PATCH] udp: make function udp_skb_dtor_locked static
Date: Wed, 17 May 2017 09:50:36 +0100
Message-ID: <20170517085036.15261-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Paolo Abeni <pabeni@redhat.com>,
        "David S . Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

Function udp_skb_dtor_locked does not need to be in global scope
so make it static to fix sparse warning:

net/ipv4/udp.c: warning: symbol 'udp_skb_dtor_locked' was not
declared. Should it be static?

Fixes: 6dfb4367cd911d ("udp: keep the sk_receive_queue held when splicing")
Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 net/ipv4/udp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 7bd56c9889b3..922a62d45714 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1218,7 +1218,7 @@ void udp_skb_destructor(struct sock *sk, struct sk_buff *skb)
 EXPORT_SYMBOL(udp_skb_destructor);
 
 /* as above, but the caller held the rx queue lock, too */
-void udp_skb_dtor_locked(struct sock *sk, struct sk_buff *skb)
+static void udp_skb_dtor_locked(struct sock *sk, struct sk_buff *skb)
 {
 	udp_rmem_release(sk, skb->dev_scratch, 1, true);
 }
-- 
2.11.0
