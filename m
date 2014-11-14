From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/1 net-next] net: dsa: replace count*size kzalloc by kcalloc
Date: Fri, 14 Nov 2014 19:38:23 +0100
Message-ID: <1415990303-28764-1-git-send-email-fabf@skynet.be>
Cc: Fabian Frederick <fabf@skynet.be>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

kcalloc manages count*sizeof overflow.

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/dsa/dsa.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 4648f12..e84b656 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -606,8 +606,8 @@ static int dsa_of_probe(struct platform_device *pdev)
 	if (pd->nr_chips > DSA_MAX_SWITCHES)
 		pd->nr_chips = DSA_MAX_SWITCHES;
 
-	pd->chip = kzalloc(pd->nr_chips * sizeof(struct dsa_chip_data),
-			GFP_KERNEL);
+	pd->chip = kcalloc(pd->nr_chips, sizeof(struct dsa_chip_data),
+			   GFP_KERNEL);
 	if (!pd->chip) {
 		ret = -ENOMEM;
 		goto out_free;
-- 
1.9.3
