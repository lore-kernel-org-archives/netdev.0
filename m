From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH 1/2] liquidio: remove unnecessary NULL check before kfree in
 delete_glists
Date: Tue, 17 Oct 2017 13:59:20 -0500
Message-ID: <20171017185920.GA16976@embeddedor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <garsilva@embeddedorcom>
To: Derek Chickles <derek.chickles@caviumnetworks.com>,
        Satanand Burla <satananda.burla@caviumnetworks.com>,
        Felix Manlunas <felix.manlunas@caviumnetworks.com>,
        Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

NULL check before freeing functions like kfree is not needed.

This issue was detected with the help of Coccinelle.

Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
---
This code was tested by compilation only.

 drivers/net/ethernet/cavium/liquidio/lio_vf_main.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
index 2e993ce..e4a112c 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
@@ -435,8 +435,7 @@ static void delete_glists(struct lio *lio)
 		do {
 			g = (struct octnic_gather *)
 			    list_delete_head(&lio->glist[i]);
-			if (g)
-				kfree(g);
+			kfree(g);
 		} while (g);
 
 		if (lio->glists_virt_base && lio->glists_virt_base[i] &&
-- 
2.7.4
