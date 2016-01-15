From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH v3 3/3] gianfar: Extend an initialisation clause of a for loop
 in gfar_ethflow_to_filer_table()
Date: Fri, 15 Jan 2016 11:14:02 +0100
Message-ID: <5698C66A.9000003@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
 <56866E7F.8080609@users.sourceforge.net>
 <5698C53C.8060204@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: netdev@vger.kernel.org,
	Claudiu Manoil <claudiu.manoil@freescale.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <5698C53C.8060204@users.sourceforge.net>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Fri, 15 Jan 2016 10:50:34 +0100

Move the assignment for the variable "j" from the beginning
into an initialisation clause of a for loop.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/ethernet/freescale/gianfar_ethtool.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar_ethtool.c b/drivers/net/ethernet/freescale/gianfar_ethtool.c
index 8302f7d..2162adc 100644
--- a/drivers/net/ethernet/freescale/gianfar_ethtool.c
+++ b/drivers/net/ethernet/freescale/gianfar_ethtool.c
@@ -772,8 +772,7 @@ static int gfar_ethflow_to_filer_table(struct gfar_private *priv, u64 ethflow,
 	unsigned int cmp_rqfpr;
 	unsigned int *local_rqfpr;
 	unsigned int *local_rqfcr;
-	int i, k, l;
-	int j = MAX_FILER_IDX;
+	int i, j, k, l;
 	int ret = 1;
 
 	local_rqfpr = kmalloc_array(MAX_FILER_IDX + 1, sizeof(unsigned int),
@@ -807,7 +806,7 @@ static int gfar_ethflow_to_filer_table(struct gfar_private *priv, u64 ethflow,
 		goto free_fcr;
 	}
 
-	for (i = 0; i < MAX_FILER_IDX + 1; i++) {
+	for (i = 0, j = MAX_FILER_IDX; i < MAX_FILER_IDX + 1; i++) {
 		local_rqfpr[j] = priv->ftp_rqfpr[i];
 		local_rqfcr[j] = priv->ftp_rqfcr[i];
 		j--;
-- 
2.6.3

