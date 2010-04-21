From: Roland Dreier <rdreier@cisco.com>
Subject: cxgb4: Make unnecessarily global functions static
Date: Wed, 21 Apr 2010 11:59:17 -0700
Message-ID: <adapr1spr7e.fsf@roland-alpha.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Dimitris Michailidis <dm@chelsio.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:45412 "EHLO
	sj-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752828Ab0DUS7W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Apr 2010 14:59:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also put t4_write_indirect() inside "#if 0" to avoid a "defined but not
used" compile warning.

Signed-off-by: Roland Dreier <rolandd@cisco.com>
---
 drivers/net/cxgb4/cxgb4.h |    2 --
 drivers/net/cxgb4/sge.c   |    2 +-
 drivers/net/cxgb4/t4_hw.c |   22 ++++++++++++----------
 3 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/drivers/net/cxgb4/cxgb4.h b/drivers/net/cxgb4/cxgb4.h
index 3d8ff48..4b35dc7 100644
--- a/drivers/net/cxgb4/cxgb4.h
+++ b/drivers/net/cxgb4/cxgb4.h
@@ -651,8 +651,6 @@ int t4_link_start(struct adapter *adap, unsigned int mbox, unsigned int port,
 		  struct link_config *lc);
 int t4_restart_aneg(struct adapter *adap, unsigned int mbox, unsigned int port);
 int t4_seeprom_wp(struct adapter *adapter, bool enable);
-int t4_read_flash(struct adapter *adapter, unsigned int addr,
-		  unsigned int nwords, u32 *data, int byte_oriented);
 int t4_load_fw(struct adapter *adapter, const u8 *fw_data, unsigned int size);
 int t4_check_fw_version(struct adapter *adapter);
 int t4_prep_adapter(struct adapter *adapter);
diff --git a/drivers/net/cxgb4/sge.c b/drivers/net/cxgb4/sge.c
index 14adc58..04e5710 100644
--- a/drivers/net/cxgb4/sge.c
+++ b/drivers/net/cxgb4/sge.c
@@ -1471,7 +1471,7 @@ EXPORT_SYMBOL(cxgb4_pktgl_to_skb);
  *	Releases the pages of a packet gather list.  We do not own the last
  *	page on the list and do not free it.
  */
-void t4_pktgl_free(const struct pkt_gl *gl)
+static void t4_pktgl_free(const struct pkt_gl *gl)
 {
 	int n;
 	const skb_frag_t *p;
diff --git a/drivers/net/cxgb4/t4_hw.c b/drivers/net/cxgb4/t4_hw.c
index a814a3a..cadead5 100644
--- a/drivers/net/cxgb4/t4_hw.c
+++ b/drivers/net/cxgb4/t4_hw.c
@@ -53,8 +53,8 @@
  *	at the time it indicated completion is stored there.  Returns 0 if the
  *	operation completes and	-EAGAIN	otherwise.
  */
-int t4_wait_op_done_val(struct adapter *adapter, int reg, u32 mask,
-			int polarity, int attempts, int delay, u32 *valp)
+static int t4_wait_op_done_val(struct adapter *adapter, int reg, u32 mask,
+			       int polarity, int attempts, int delay, u32 *valp)
 {
 	while (1) {
 		u32 val = t4_read_reg(adapter, reg);
@@ -109,9 +109,9 @@ void t4_set_reg_field(struct adapter *adapter, unsigned int addr, u32 mask,
  *	Reads registers that are accessed indirectly through an address/data
  *	register pair.
  */
-void t4_read_indirect(struct adapter *adap, unsigned int addr_reg,
-		      unsigned int data_reg, u32 *vals, unsigned int nregs,
-		      unsigned int start_idx)
+static void t4_read_indirect(struct adapter *adap, unsigned int addr_reg,
+			     unsigned int data_reg, u32 *vals,
+			     unsigned int nregs, unsigned int start_idx)
 {
 	while (nregs--) {
 		t4_write_reg(adap, addr_reg, start_idx);
@@ -120,6 +120,7 @@ void t4_read_indirect(struct adapter *adap, unsigned int addr_reg,
 	}
 }
 
+#if 0
 /**
  *	t4_write_indirect - write indirectly addressed registers
  *	@adap: the adapter
@@ -132,15 +133,16 @@ void t4_read_indirect(struct adapter *adap, unsigned int addr_reg,
  *	Writes a sequential block of registers that are accessed indirectly
  *	through an address/data register pair.
  */
-void t4_write_indirect(struct adapter *adap, unsigned int addr_reg,
-		       unsigned int data_reg, const u32 *vals,
-		       unsigned int nregs, unsigned int start_idx)
+static void t4_write_indirect(struct adapter *adap, unsigned int addr_reg,
+			      unsigned int data_reg, const u32 *vals,
+			      unsigned int nregs, unsigned int start_idx)
 {
 	while (nregs--) {
 		t4_write_reg(adap, addr_reg, start_idx++);
 		t4_write_reg(adap, data_reg, *vals++);
 	}
 }
+#endif
 
 /*
  * Get the reply to a mailbox command and store it in @rpl in big-endian order.
@@ -537,8 +539,8 @@ static int flash_wait_op(struct adapter *adapter, int attempts, int delay)
  *	(i.e., big-endian), otherwise as 32-bit words in the platform's
  *	natural endianess.
  */
-int t4_read_flash(struct adapter *adapter, unsigned int addr,
-		  unsigned int nwords, u32 *data, int byte_oriented)
+static int t4_read_flash(struct adapter *adapter, unsigned int addr,
+			 unsigned int nwords, u32 *data, int byte_oriented)
 {
 	int ret;
 

-- 
Roland Dreier <rolandd@cisco.com> || For corporate legal information go to:
http://www.cisco.com/web/about/doing_business/legal/cri/index.html
