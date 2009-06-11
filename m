From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [2.6.31 15/21] wimax/i2400m/sdio: Add device specific poke table.
Date: Thu, 11 Jun 2009 14:35:52 -0700
Message-ID: <1c0b2dd75772cbce0aef8886b7f38313542216de.1244755662.git.inaky@linux.intel.com>
References: <cover.1244755662.git.inaky@linux.intel.com>
Cc: Dirk Brandewie <dirk.j.brandewie@intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:28457 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756161AbZFKVgt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jun 2009 17:36:49 -0400
In-Reply-To: <cover.1244755662.git.inaky@linux.intel.com>
In-Reply-To: <cover.1244755662.git.inaky@linux.intel.com>
References: <cover.1244755662.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dirk Brandewie <dirk.j.brandewie@intel.com>

Add a poke table for the SDIO device (as it is different than USB).

Signed-off-by: Dirk Brandewie <dirk.j.brandewie@intel.com>
---
 drivers/net/wimax/i2400m/sdio.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wimax/i2400m/sdio.c b/drivers/net/wimax/i2400m/sdio.c
index afde897..74de174 100644
--- a/drivers/net/wimax/i2400m/sdio.c
+++ b/drivers/net/wimax/i2400m/sdio.c
@@ -78,6 +78,14 @@ static const char *i2400ms_bus_fw_names[] = {
 };
 
 
+static const struct i2400m_poke_table i2400ms_pokes[] = {
+	I2400M_FW_POKE(0x6BE260, 0x00000088),
+	I2400M_FW_POKE(0x080550, 0x00000005),
+	I2400M_FW_POKE(0xAE0000, 0x00000000),
+	I2400M_FW_POKE(0x000000, 0x00000000), /* MUST be 0 terminated or bad
+					       * things will happen */
+};
+
 /*
  * Enable the SDIO function
  *
@@ -425,6 +433,7 @@ int i2400ms_probe(struct sdio_func *func,
 	i2400m->bus_bm_wait_for_ack = i2400ms_bus_bm_wait_for_ack;
 	i2400m->bus_fw_names = i2400ms_bus_fw_names;
 	i2400m->bus_bm_mac_addr_impaired = 1;
+	i2400m->bus_bm_pokes_table = &i2400ms_pokes[0];
 
 	sdio_claim_host(func);
 	result = sdio_set_block_size(func, I2400MS_BLK_SIZE);
-- 
1.6.2.3

