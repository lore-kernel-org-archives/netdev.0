From: Colin King <colin.king@canonical.com>
Subject: [PATCH][net-next] esp6: fix incorrect null pointer check on xo
Date: Tue, 18 Apr 2017 15:06:53 +0100
Message-ID: <20170418140653.8839-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

The check for xo being null is incorrect, currently it is checking
for non-null, it should be checking for null.

Detected with CoverityScan, CID#1429349 ("Dereference after null check")

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 net/ipv6/esp6_offload.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/esp6_offload.c b/net/ipv6/esp6_offload.c
index 1cceeee7cc33..95f10728abaa 100644
--- a/net/ipv6/esp6_offload.c
+++ b/net/ipv6/esp6_offload.c
@@ -120,7 +120,7 @@ static struct sk_buff *esp6_gso_segment(struct sk_buff *skb,
 	netdev_features_t esp_features = features;
 	struct xfrm_offload *xo = xfrm_offload(skb);
 
-	if (xo)
+	if (!xo)
 		goto out;
 
 	seq = xo->seq.low;
-- 
2.11.0
