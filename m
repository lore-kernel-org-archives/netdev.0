From: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
Subject: [PATCH 76] drivers/net/via-velocity.c: mostly kmalloc + memset conversion to kcalloc
Date: Wed, 1 Aug 2007 00:11:50 +0200
Message-ID: <200708010011.50979.m.kozlowski@tuxland.pl>
References: <200707311845.48807.m.kozlowski@tuxland.pl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-2"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	romieu@fr.zoreil.com, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <200707311845.48807.m.kozlowski@tuxland.pl>
Content-Disposition: inline
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Mariusz Kozlowski <m.kozlowski@tuxland.pl>

 drivers/net/via-velocity.c | 88263 -> 88120 (-143 bytes)
 drivers/net/via-velocity.o | 254264 -> 253828 (-436 bytes)

 drivers/net/via-velocity.c |   24 ++++++++++--------------
 1 file changed, 10 insertions(+), 14 deletions(-)

--- linux-2.6.23-rc1-mm1-a/drivers/net/via-velocity.c	2007-07-26 13:07:43.000000000 +0200
+++ linux-2.6.23-rc1-mm1-b/drivers/net/via-velocity.c	2007-07-31 13:50:28.000000000 +0200
@@ -1071,14 +1071,12 @@ static int velocity_rx_refill(struct vel

 static int velocity_init_rd_ring(struct velocity_info *vptr)
 {
-	int ret = -ENOMEM;
-	unsigned int rsize = sizeof(struct velocity_rd_info) *
-					vptr->options.numrx;
+	int ret;

-	vptr->rd_info = kmalloc(rsize, GFP_KERNEL);
-	if(vptr->rd_info == NULL)
-		goto out;
-	memset(vptr->rd_info, 0, rsize);
+	vptr->rd_info = kcalloc(vptr->options.numrx,
+				sizeof(struct velocity_rd_info), GFP_KERNEL);
+	if (!vptr->rd_info)
+		return -ENOMEM;

 	vptr->rd_filled = vptr->rd_dirty = vptr->rd_curr = 0;

@@ -1088,7 +1086,7 @@ static int velocity_init_rd_ring(struct
 			"%s: failed to allocate RX buffer.\n", vptr->dev->name);
 		velocity_free_rd_ring(vptr);
 	}
-out:
+
 	return ret;
 }

@@ -1142,21 +1140,19 @@ static int velocity_init_td_ring(struct
 	dma_addr_t curr;
 	struct tx_desc *td;
 	struct velocity_td_info *td_info;
-	unsigned int tsize = sizeof(struct velocity_td_info) *
-					vptr->options.numtx;

 	/* Init the TD ring entries */
 	for (j = 0; j < vptr->num_txq; j++) {
 		curr = vptr->td_pool_dma[j];

-		vptr->td_infos[j] = kmalloc(tsize, GFP_KERNEL);
-		if(vptr->td_infos[j] == NULL)
-		{
+		vptr->td_infos[j] = kcalloc(vptr->options.numtx,
+					    sizeof(struct velocity_td_info),
+					    GFP_KERNEL);
+		if (!vptr->td_infos[j])	{
 			while(--j >= 0)
 				kfree(vptr->td_infos[j]);
 			return -ENOMEM;
 		}
-		memset(vptr->td_infos[j], 0, tsize);

 		for (i = 0; i < vptr->options.numtx; i++, curr += sizeof(struct tx_desc)) {
 			td = &(vptr->td_rings[j][i]);
