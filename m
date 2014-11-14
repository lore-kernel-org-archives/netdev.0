From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/1 net-next] net: dsa: replace count*size kmalloc by kmalloc_array
Date: Fri, 14 Nov 2014 19:36:42 +0100
Message-ID: <1415990202-28673-1-git-send-email-fabf@skynet.be>
Cc: Fabian Frederick <fabf@skynet.be>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

kmalloc_array manages count*sizeof overflow.

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/dsa/dsa.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 4648f12..c00cca3 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -526,7 +526,8 @@ static int dsa_of_setup_routing_table(struct dsa_platform_data *pd,
 
 	/* First time routing table allocation */
 	if (!cd->rtable) {
-		cd->rtable = kmalloc(pd->nr_chips * sizeof(s8), GFP_KERNEL);
+		cd->rtable = kmalloc_array(pd->nr_chips, sizeof(s8),
+					   GFP_KERNEL);
 		if (!cd->rtable)
 			return -ENOMEM;
 
-- 
1.9.3
