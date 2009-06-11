From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [2.6.31 05/21] wimax/i2400m: Change d_printf() level for secure boot messages
Date: Thu, 11 Jun 2009 14:35:42 -0700
Message-ID: <ead68239913cb9c19150facf1656517f81d66fcb.1244755662.git.inaky@linux.intel.com>
References: <cover.1244755662.git.inaky@linux.intel.com>
Cc: Dirk Brandewie <dirk.j.brandewie@intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:27879 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756043AbZFKVgt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jun 2009 17:36:49 -0400
In-Reply-To: <cover.1244755662.git.inaky@linux.intel.com>
In-Reply-To: <cover.1244755662.git.inaky@linux.intel.com>
References: <cover.1244755662.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dirk Brandewie <dirk.j.brandewie@intel.com>

Changing debug level of print out to support validation engineers
getting the messages they need.

Signed-off-by:  <dirk.j.brandewie@intel.com>
---
 drivers/net/wimax/i2400m/fw.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wimax/i2400m/fw.c b/drivers/net/wimax/i2400m/fw.c
index 675c6ce..7ee1b99 100644
--- a/drivers/net/wimax/i2400m/fw.c
+++ b/drivers/net/wimax/i2400m/fw.c
@@ -532,14 +532,14 @@ int i2400m_dnload_finalize(struct i2400m *i2400m,
 	cmd = (void *) bcf + offset;
 	if (i2400m->sboot == 0) {
 		struct i2400m_bootrom_header jump_ack;
-		d_printf(3, dev, "unsecure boot, jumping to 0x%08x\n",
+		d_printf(1, dev, "unsecure boot, jumping to 0x%08x\n",
 			le32_to_cpu(cmd->target_addr));
 		i2400m_brh_set_opcode(cmd, I2400M_BRH_JUMP);
 		cmd->data_size = 0;
 		ret = i2400m_bm_cmd(i2400m, cmd, sizeof(*cmd),
 				    &jump_ack, sizeof(jump_ack), 0);
 	} else {
-		d_printf(3, dev, "secure boot, jumping to 0x%08x\n",
+		d_printf(1, dev, "secure boot, jumping to 0x%08x\n",
 			 le32_to_cpu(cmd->target_addr));
 		cmd_buf = i2400m->bm_cmd_buf;
 		memcpy(&cmd_buf->cmd, cmd, sizeof(*cmd));
-- 
1.6.2.3

