From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [patch 2.6.35 19/25] wimax/i2400m: SDIO specific TX queue's minimum buffer room for new message
Date: Fri, 14 May 2010 14:45:18 -0700
Message-ID: <8a3a1b65eeecd18357ac0cc941f43df153d4f271.1273708027.git.inaky.perez-gonzalez@intel.com>
References: <cover.1273708027.git.inaky.perez-gonzalez@intel.com>
Cc: "Prasanna S. Panchamukhi" <prasannax.s.panchamukhi@intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:59847 "EHLO
	fmsmga101.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932546Ab0ENVtS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 May 2010 17:49:18 -0400
In-Reply-To: <cover.1273708027.git.inaky.perez-gonzalez@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Prasanna S. Panchamukhi <prasannax.s.panchamukhi@intel.com>

This patch specifies the TX queue's minimum buffer room required to
accommodate one smallest SDIO payload.
Please refer the documentation in the code.

Signed-off-by: Prasanna S. Panchamukhi <prasannax.s.panchamukhi@intel.com>
---
 drivers/net/wimax/i2400m/sdio.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wimax/i2400m/sdio.c b/drivers/net/wimax/i2400m/sdio.c
index 7632f80..9bfc26e 100644
--- a/drivers/net/wimax/i2400m/sdio.c
+++ b/drivers/net/wimax/i2400m/sdio.c
@@ -483,6 +483,13 @@ int i2400ms_probe(struct sdio_func *func,
 	sdio_set_drvdata(func, i2400ms);
 
 	i2400m->bus_tx_block_size = I2400MS_BLK_SIZE;
+	/*
+	 * Room required in the TX queue for SDIO message to accommodate
+	 * a smallest payload while allocating header space is 224 bytes,
+	 * which is the smallest message size(the block size 256 bytes)
+	 * minus the smallest message header size(32 bytes).
+	 */
+	i2400m->bus_tx_room_min = I2400MS_BLK_SIZE - I2400M_PL_ALIGN * 2;
 	i2400m->bus_pl_size_max = I2400MS_PL_SIZE_MAX;
 	i2400m->bus_setup = i2400ms_bus_setup;
 	i2400m->bus_dev_start = i2400ms_bus_dev_start;
-- 
1.6.6.1

