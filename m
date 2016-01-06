From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch -next] fsl/fman: use the ALIGN() macro
Date: Wed, 6 Jan 2016 13:03:08 +0300
Message-ID: <20160106100308.GE23185@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Igal Liberman <igal.liberman@freescale.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The original code works fine but the issue is that static checkers
complain about this:

	~(u16)(OFFSET_UNITS - 1)

In that expression the cast to u16 is a no-op because we cast the value
15 to a u16 but then type promotion rules automatically cast it back to
an int and then we do the bitwise negate.

It's cleaner to use the kernel's ALIGN() macro instead.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
I think this patch is correct, but I haven't tested it, so please review
carefully.

diff --git a/drivers/net/ethernet/freescale/fman/fman_sp.c b/drivers/net/ethernet/freescale/fman/fman_sp.c
index f9e7aa3..b527da1 100644
--- a/drivers/net/ethernet/freescale/fman/fman_sp.c
+++ b/drivers/net/ethernet/freescale/fman/fman_sp.c
@@ -92,11 +92,8 @@ int fman_sp_build_buffer_struct(struct fman_sp_int_context_data_copy *
 	u32 tmp;
 
 	/* Align start of internal context data to 16 byte */
-	int_context_data_copy->ext_buf_offset = (u16)
-		((buffer_prefix_content->priv_data_size & (OFFSET_UNITS - 1)) ?
-		((buffer_prefix_content->priv_data_size + OFFSET_UNITS) &
-			~(u16)(OFFSET_UNITS - 1)) :
-		buffer_prefix_content->priv_data_size);
+	int_context_data_copy->ext_buf_offset =
+		(u16)ALIGN(buffer_prefix_content->priv_data_size, 16);
 
 	/* Translate margin and int_context params to FM parameters */
 	/* Initialize with illegal value. Later we'll set legal values. */
