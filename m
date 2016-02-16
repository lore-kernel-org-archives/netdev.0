From: Insu Yun <wuninsu@gmail.com>
Subject: [PATCH] tcp: correctly crypto_alloc_hash return check
Date: Mon, 15 Feb 2016 21:30:33 -0500
Message-ID: <1455589833-7571-1-git-send-email-wuninsu@gmail.com>
Cc: taesoo@gatech.edu, yeongjin.jang@gatech.edu, insu@gatech.edu,
	changwoo@gatech.edu, Insu Yun <wuninsu@gmail.com>
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

crypto_alloc_hash never returns NULL

Signed-off-by: Insu Yun <wuninsu@gmail.com>
---
 net/ipv4/tcp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index fd17eec..a95aac1 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2946,7 +2946,7 @@ static void __tcp_alloc_md5sig_pool(void)
 			struct crypto_hash *hash;
 
 			hash = crypto_alloc_hash("md5", 0, CRYPTO_ALG_ASYNC);
-			if (IS_ERR_OR_NULL(hash))
+			if (IS_ERR(hash))
 				return;
 			per_cpu(tcp_md5sig_pool, cpu).md5_desc.tfm = hash;
 		}
-- 
1.9.1
