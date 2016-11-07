From: Shuah Khan <shuahkh@osg.samsung.com>
Subject: [PATCH] net/netfilter: Fix use uninitialized warn in nft_range_eval()
Date: Mon,  7 Nov 2016 08:41:14 -0700
Message-ID: <20161107154114.26803-4-shuahkh@osg.samsung.com>
References: <20161107154114.26803-1-shuahkh@osg.samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Shuah Khan <shuahkh@osg.samsung.com>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
        davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161107154114.26803-1-shuahkh@osg.samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix the following warn:

   CC [M]  net/netfilter/nft_range.o
8601,8605c9105
 net/netfilter/nft_range.c: In function ‘nft_range_eval’:
 net/netfilter/nft_range.c:45:5: warning: ‘mismatch’ may be used uninitialized in this function [-Wmaybe-uninitialized]
   if (mismatch)
      ^

Signed-off-by: Shuah Khan <shuahkh@osg.samsung.com>
---
 net/netfilter/nft_range.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nft_range.c b/net/netfilter/nft_range.c
index c6d5358..fe5f69b 100644
--- a/net/netfilter/nft_range.c
+++ b/net/netfilter/nft_range.c
@@ -28,7 +28,7 @@ static void nft_range_eval(const struct nft_expr *expr,
 			 const struct nft_pktinfo *pkt)
 {
 	const struct nft_range_expr *priv = nft_expr_priv(expr);
-	bool mismatch;
+	bool mismatch = false;
 	int d1, d2;
 
 	d1 = memcmp(&regs->data[priv->sreg], &priv->data_from, priv->len);
-- 
2.9.3
