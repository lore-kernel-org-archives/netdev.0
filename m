From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 06/10] ixgbe: Add Flow Director init and modify
	functions for 82599
Date: Thu, 04 Jun 2009 19:01:25 -0700
Message-ID: <20090605020125.8468.84715.stgit@localhost.localdomain>
References: <20090605015948.8468.25862.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta01.emeryville.ca.mail.comcast.net ([76.96.30.16]:59348 "EHLO
	QMTA01.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751364AbZFECBk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2009 22:01:40 -0400
In-Reply-To: <20090605015948.8468.25862.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>

This patch adds the functions for ixgbe to initialize Flow Director.  It
also has the function APIs to add Flow Director filters from the base
driver.  This also includes ATR, Application Targeted Routing, which is a
feature set of Flow Director.  This is the hash-based mechanism to
automatically identify flows and add filters based on the hash, and direct
the Rx of that flow back to that same CPU.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe.h       |   55 ++
 drivers/net/ixgbe/ixgbe_82599.c |  925 +++++++++++++++++++++++++++++++++++++++
 2 files changed, 980 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 59167d7..7adf959 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -402,6 +402,61 @@ extern int ixgbe_init_interrupt_scheme(struct ixgbe_adapter *adapter);
 extern void ixgbe_clear_interrupt_scheme(struct ixgbe_adapter *adapter);
 extern void ixgbe_write_eitr(struct ixgbe_q_vector *);
 extern int ethtool_ioctl(struct ifreq *ifr);
+extern s32 ixgbe_reinit_fdir_tables_82599(struct ixgbe_hw *hw);
+extern s32 ixgbe_init_fdir_signature_82599(struct ixgbe_hw *hw, u32 pballoc);
+extern s32 ixgbe_init_fdir_perfect_82599(struct ixgbe_hw *hw, u32 pballoc);
+extern s32 ixgbe_fdir_add_signature_filter_82599(struct ixgbe_hw *hw,
+                                                 struct ixgbe_atr_input *input,
+                                                 u8 queue);
+extern s32 ixgbe_fdir_add_perfect_filter_82599(struct ixgbe_hw *hw,
+                                               struct ixgbe_atr_input *input,
+                                               u16 soft_id,
+                                               u8 queue);
+extern u16 ixgbe_atr_compute_hash_82599(struct ixgbe_atr_input *input, u32 key);
+extern s32 ixgbe_atr_set_vlan_id_82599(struct ixgbe_atr_input *input,
+                                       u16 vlan_id);
+extern s32 ixgbe_atr_set_src_ipv4_82599(struct ixgbe_atr_input *input,
+                                        u32 src_addr);
+extern s32 ixgbe_atr_set_dst_ipv4_82599(struct ixgbe_atr_input *input,
+                                        u32 dst_addr);
+extern s32 ixgbe_atr_set_src_ipv6_82599(struct ixgbe_atr_input *input,
+                                        u32 src_addr_1, u32 src_addr_2,
+                                        u32 src_addr_3, u32 src_addr_4);
+extern s32 ixgbe_atr_set_dst_ipv6_82599(struct ixgbe_atr_input *input,
+                                        u32 dst_addr_1, u32 dst_addr_2,
+                                        u32 dst_addr_3, u32 dst_addr_4);
+extern s32 ixgbe_atr_set_src_port_82599(struct ixgbe_atr_input *input,
+                                        u16 src_port);
+extern s32 ixgbe_atr_set_dst_port_82599(struct ixgbe_atr_input *input,
+                                        u16 dst_port);
+extern s32 ixgbe_atr_set_flex_byte_82599(struct ixgbe_atr_input *input,
+                                         u16 flex_byte);
+extern s32 ixgbe_atr_set_vm_pool_82599(struct ixgbe_atr_input *input,
+                                       u8 vm_pool);
+extern s32 ixgbe_atr_set_l4type_82599(struct ixgbe_atr_input *input,
+                                      u8 l4type);
+extern s32 ixgbe_atr_get_vlan_id_82599(struct ixgbe_atr_input *input,
+                                       u16 *vlan_id);
+extern s32 ixgbe_atr_get_src_ipv4_82599(struct ixgbe_atr_input *input,
+                                        u32 *src_addr);
+extern s32 ixgbe_atr_get_dst_ipv4_82599(struct ixgbe_atr_input *input,
+                                        u32 *dst_addr);
+extern s32 ixgbe_atr_get_src_ipv6_82599(struct ixgbe_atr_input *input,
+                                        u32 *src_addr_1, u32 *src_addr_2,
+                                        u32 *src_addr_3, u32 *src_addr_4);
+extern s32 ixgbe_atr_get_dst_ipv6_82599(struct ixgbe_atr_input *input,
+                                        u32 *dst_addr_1, u32 *dst_addr_2,
+                                        u32 *dst_addr_3, u32 *dst_addr_4);
+extern s32 ixgbe_atr_get_src_port_82599(struct ixgbe_atr_input *input,
+                                        u16 *src_port);
+extern s32 ixgbe_atr_get_dst_port_82599(struct ixgbe_atr_input *input,
+                                        u16 *dst_port);
+extern s32 ixgbe_atr_get_flex_byte_82599(struct ixgbe_atr_input *input,
+                                         u16 *flex_byte);
+extern s32 ixgbe_atr_get_vm_pool_82599(struct ixgbe_atr_input *input,
+                                       u8 *vm_pool);
+extern s32 ixgbe_atr_get_l4type_82599(struct ixgbe_atr_input *input,
+                                      u8 *l4type);
 #ifdef IXGBE_FCOE
 extern void ixgbe_configure_fcoe(struct ixgbe_adapter *adapter);
 extern int ixgbe_fso(struct ixgbe_adapter *adapter,
diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
index 3f36d83..5c2627b 100644
--- a/drivers/net/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -1165,6 +1165,931 @@ s32 ixgbe_init_uta_tables_82599(struct ixgbe_hw *hw)
 }
 
 /**
+ *  ixgbe_reinit_fdir_tables_82599 - Reinitialize Flow Director tables.
+ *  @hw: pointer to hardware structure
+ **/
+s32 ixgbe_reinit_fdir_tables_82599(struct ixgbe_hw *hw)
+{
+	int i;
+	u32 fdirctrl = IXGBE_READ_REG(hw, IXGBE_FDIRCTRL);
+	fdirctrl &= ~IXGBE_FDIRCTRL_INIT_DONE;
+
+	/*
+	 * Before starting reinitialization process,
+	 * FDIRCMD.CMD must be zero.
+	 */
+	for (i = 0; i < IXGBE_FDIRCMD_CMD_POLL; i++) {
+		if (!(IXGBE_READ_REG(hw, IXGBE_FDIRCMD) &
+		      IXGBE_FDIRCMD_CMD_MASK))
+			break;
+		udelay(10);
+	}
+	if (i >= IXGBE_FDIRCMD_CMD_POLL) {
+		hw_dbg(hw ,"Flow Director previous command isn't complete, "
+		       "aborting table re-initialization. \n");
+		return IXGBE_ERR_FDIR_REINIT_FAILED;
+	}
+
+	IXGBE_WRITE_REG(hw, IXGBE_FDIRFREE, 0);
+	IXGBE_WRITE_FLUSH(hw);
+	/*
+	 * 82599 adapters flow director init flow cannot be restarted,
+	 * Workaround 82599 silicon errata by performing the following steps
+	 * before re-writing the FDIRCTRL control register with the same value.
+	 * - write 1 to bit 8 of FDIRCMD register &
+	 * - write 0 to bit 8 of FDIRCMD register
+	 */
+	IXGBE_WRITE_REG(hw, IXGBE_FDIRCMD,
+	                (IXGBE_READ_REG(hw, IXGBE_FDIRCMD) |
+	                 IXGBE_FDIRCMD_CLEARHT));
+	IXGBE_WRITE_FLUSH(hw);
+	IXGBE_WRITE_REG(hw, IXGBE_FDIRCMD,
+	                (IXGBE_READ_REG(hw, IXGBE_FDIRCMD) &
+	                 ~IXGBE_FDIRCMD_CLEARHT));
+	IXGBE_WRITE_FLUSH(hw);
+	/*
+	 * Clear FDIR Hash register to clear any leftover hashes
+	 * waiting to be programmed.
+	 */
+	IXGBE_WRITE_REG(hw, IXGBE_FDIRHASH, 0x00);
+	IXGBE_WRITE_FLUSH(hw);
+
+	IXGBE_WRITE_REG(hw, IXGBE_FDIRCTRL, fdirctrl);
+	IXGBE_WRITE_FLUSH(hw);
+
+	/* Poll init-done after we write FDIRCTRL register */
+	for (i = 0; i < IXGBE_FDIR_INIT_DONE_POLL; i++) {
+		if (IXGBE_READ_REG(hw, IXGBE_FDIRCTRL) &
+		                   IXGBE_FDIRCTRL_INIT_DONE)
+			break;
+		udelay(10);
+	}
+	if (i >= IXGBE_FDIR_INIT_DONE_POLL) {
+		hw_dbg(hw, "Flow Director Signature poll time exceeded!\n");
+		return IXGBE_ERR_FDIR_REINIT_FAILED;
+	}
+
+	/* Clear FDIR statistics registers (read to clear) */
+	IXGBE_READ_REG(hw, IXGBE_FDIRUSTAT);
+	IXGBE_READ_REG(hw, IXGBE_FDIRFSTAT);
+	IXGBE_READ_REG(hw, IXGBE_FDIRMATCH);
+	IXGBE_READ_REG(hw, IXGBE_FDIRMISS);
+	IXGBE_READ_REG(hw, IXGBE_FDIRLEN);
+
+	return 0;
+}
+
+/**
+ *  ixgbe_init_fdir_signature_82599 - Initialize Flow Director signature filters
+ *  @hw: pointer to hardware structure
+ *  @pballoc: which mode to allocate filters with
+ **/
+s32 ixgbe_init_fdir_signature_82599(struct ixgbe_hw *hw, u32 pballoc)
+{
+	u32 fdirctrl = 0;
+	u32 pbsize;
+	int i;
+
+	/*
+	 * Before enabling Flow Director, the Rx Packet Buffer size
+	 * must be reduced.  The new value is the current size minus
+	 * flow director memory usage size.
+	 */
+	pbsize = (1 << (IXGBE_FDIR_PBALLOC_SIZE_SHIFT + pballoc));
+	IXGBE_WRITE_REG(hw, IXGBE_RXPBSIZE(0),
+	    (IXGBE_READ_REG(hw, IXGBE_RXPBSIZE(0)) - pbsize));
+
+	/*
+	 * The defaults in the HW for RX PB 1-7 are not zero and so should be
+	 * intialized to zero for non DCB mode otherwise actual total RX PB
+	 * would be bigger than programmed and filter space would run into
+	 * the PB 0 region.
+	 */
+	for (i = 1; i < 8; i++)
+		IXGBE_WRITE_REG(hw, IXGBE_RXPBSIZE(i), 0);
+
+	/* Send interrupt when 64 filters are left */
+	fdirctrl |= 4 << IXGBE_FDIRCTRL_FULL_THRESH_SHIFT;
+
+	/* Set the maximum length per hash bucket to 0xA filters */
+	fdirctrl |= 0xA << IXGBE_FDIRCTRL_MAX_LENGTH_SHIFT;
+
+	switch (pballoc) {
+	case IXGBE_FDIR_PBALLOC_64K:
+		/* 8k - 1 signature filters */
+		fdirctrl |= IXGBE_FDIRCTRL_PBALLOC_64K;
+		break;
+	case IXGBE_FDIR_PBALLOC_128K:
+		/* 16k - 1 signature filters */
+		fdirctrl |= IXGBE_FDIRCTRL_PBALLOC_128K;
+		break;
+	case IXGBE_FDIR_PBALLOC_256K:
+		/* 32k - 1 signature filters */
+		fdirctrl |= IXGBE_FDIRCTRL_PBALLOC_256K;
+		break;
+	default:
+		/* bad value */
+		return IXGBE_ERR_CONFIG;
+	};
+
+	/* Move the flexible bytes to use the ethertype - shift 6 words */
+	fdirctrl |= (0x6 << IXGBE_FDIRCTRL_FLEX_SHIFT);
+
+	fdirctrl |= IXGBE_FDIRCTRL_REPORT_STATUS;
+
+	/* Prime the keys for hashing */
+	IXGBE_WRITE_REG(hw, IXGBE_FDIRHKEY,
+	                htonl(IXGBE_ATR_BUCKET_HASH_KEY));
+	IXGBE_WRITE_REG(hw, IXGBE_FDIRSKEY,
+	                htonl(IXGBE_ATR_SIGNATURE_HASH_KEY));
+
+	/*
+	 * Poll init-done after we write the register.  Estimated times:
+	 *      10G: PBALLOC = 11b, timing is 60us
+	 *       1G: PBALLOC = 11b, timing is 600us
+	 *     100M: PBALLOC = 11b, timing is 6ms
+	 *
+	 *     Multiple these timings by 4 if under full Rx load
+	 *
+	 * So we'll poll for IXGBE_FDIR_INIT_DONE_POLL times, sleeping for
+	 * 1 msec per poll time.  If we're at line rate and drop to 100M, then
+	 * this might not finish in our poll time, but we can live with that
+	 * for now.
+	 */
+	IXGBE_WRITE_REG(hw, IXGBE_FDIRCTRL, fdirctrl);
+	IXGBE_WRITE_FLUSH(hw);
+	for (i = 0; i < IXGBE_FDIR_INIT_DONE_POLL; i++) {
+		if (IXGBE_READ_REG(hw, IXGBE_FDIRCTRL) &
+		                   IXGBE_FDIRCTRL_INIT_DONE)
+			break;
+		msleep(1);
+	}
+	if (i >= IXGBE_FDIR_INIT_DONE_POLL)
+		hw_dbg(hw, "Flow Director Signature poll time exceeded!\n");
+
+	return 0;
+}
+
+/**
+ *  ixgbe_init_fdir_perfect_82599 - Initialize Flow Director perfect filters
+ *  @hw: pointer to hardware structure
+ *  @pballoc: which mode to allocate filters with
+ **/
+s32 ixgbe_init_fdir_perfect_82599(struct ixgbe_hw *hw, u32 pballoc)
+{
+	u32 fdirctrl = 0;
+	u32 pbsize;
+	int i;
+
+	/*
+	 * Before enabling Flow Director, the Rx Packet Buffer size
+	 * must be reduced.  The new value is the current size minus
+	 * flow director memory usage size.
+	 */
+	pbsize = (1 << (IXGBE_FDIR_PBALLOC_SIZE_SHIFT + pballoc));
+	IXGBE_WRITE_REG(hw, IXGBE_RXPBSIZE(0),
+	    (IXGBE_READ_REG(hw, IXGBE_RXPBSIZE(0)) - pbsize));
+
+	/*
+	 * The defaults in the HW for RX PB 1-7 are not zero and so should be
+	 * intialized to zero for non DCB mode otherwise actual total RX PB
+	 * would be bigger than programmed and filter space would run into
+	 * the PB 0 region.
+	 */
+	for (i = 1; i < 8; i++)
+		IXGBE_WRITE_REG(hw, IXGBE_RXPBSIZE(i), 0);
+
+	/* Send interrupt when 64 filters are left */
+	fdirctrl |= 4 << IXGBE_FDIRCTRL_FULL_THRESH_SHIFT;
+
+	switch (pballoc) {
+	case IXGBE_FDIR_PBALLOC_64K:
+		/* 2k - 1 perfect filters */
+		fdirctrl |= IXGBE_FDIRCTRL_PBALLOC_64K;
+		break;
+	case IXGBE_FDIR_PBALLOC_128K:
+		/* 4k - 1 perfect filters */
+		fdirctrl |= IXGBE_FDIRCTRL_PBALLOC_128K;
+		break;
+	case IXGBE_FDIR_PBALLOC_256K:
+		/* 8k - 1 perfect filters */
+		fdirctrl |= IXGBE_FDIRCTRL_PBALLOC_256K;
+		break;
+	default:
+		/* bad value */
+		return IXGBE_ERR_CONFIG;
+	};
+
+	/* Turn perfect match filtering on */
+	fdirctrl |= IXGBE_FDIRCTRL_PERFECT_MATCH;
+	fdirctrl |= IXGBE_FDIRCTRL_REPORT_STATUS;
+
+	/* Move the flexible bytes to use the ethertype - shift 6 words */
+	fdirctrl |= (0x6 << IXGBE_FDIRCTRL_FLEX_SHIFT);
+
+	/* Prime the keys for hashing */
+	IXGBE_WRITE_REG(hw, IXGBE_FDIRHKEY,
+	                htonl(IXGBE_ATR_BUCKET_HASH_KEY));
+	IXGBE_WRITE_REG(hw, IXGBE_FDIRSKEY,
+	                htonl(IXGBE_ATR_SIGNATURE_HASH_KEY));
+
+	/*
+	 * Poll init-done after we write the register.  Estimated times:
+	 *      10G: PBALLOC = 11b, timing is 60us
+	 *       1G: PBALLOC = 11b, timing is 600us
+	 *     100M: PBALLOC = 11b, timing is 6ms
+	 *
+	 *     Multiple these timings by 4 if under full Rx load
+	 *
+	 * So we'll poll for IXGBE_FDIR_INIT_DONE_POLL times, sleeping for
+	 * 1 msec per poll time.  If we're at line rate and drop to 100M, then
+	 * this might not finish in our poll time, but we can live with that
+	 * for now.
+	 */
+
+	/* Set the maximum length per hash bucket to 0xA filters */
+	fdirctrl |= (0xA << IXGBE_FDIRCTRL_MAX_LENGTH_SHIFT);
+
+	IXGBE_WRITE_REG(hw, IXGBE_FDIRCTRL, fdirctrl);
+	IXGBE_WRITE_FLUSH(hw);
+	for (i = 0; i < IXGBE_FDIR_INIT_DONE_POLL; i++) {
+		if (IXGBE_READ_REG(hw, IXGBE_FDIRCTRL) &
+		                   IXGBE_FDIRCTRL_INIT_DONE)
+			break;
+		msleep(1);
+	}
+	if (i >= IXGBE_FDIR_INIT_DONE_POLL)
+		hw_dbg(hw, "Flow Director Perfect poll time exceeded!\n");
+
+	return 0;
+}
+
+
+/**
+ *  ixgbe_atr_compute_hash_82599 - Compute the hashes for SW ATR
+ *  @stream: input bitstream to compute the hash on
+ *  @key: 32-bit hash key
+ **/
+u16 ixgbe_atr_compute_hash_82599(struct ixgbe_atr_input *atr_input, u32 key)
+{
+	/*
+	 * The algorithm is as follows:
+	 *    Hash[15:0] = Sum { S[n] x K[n+16] }, n = 0...350
+	 *    where Sum {A[n]}, n = 0...n is bitwise XOR of A[0], A[1]...A[n]
+	 *    and A[n] x B[n] is bitwise AND between same length strings
+	 *
+	 *    K[n] is 16 bits, defined as:
+	 *       for n modulo 32 >= 15, K[n] = K[n % 32 : (n % 32) - 15]
+	 *       for n modulo 32 < 15, K[n] =
+	 *             K[(n % 32:0) | (31:31 - (14 - (n % 32)))]
+	 *
+	 *    S[n] is 16 bits, defined as:
+	 *       for n >= 15, S[n] = S[n:n - 15]
+	 *       for n < 15, S[n] = S[(n:0) | (350:350 - (14 - n))]
+	 *
+	 *    To simplify for programming, the algorithm is implemented
+	 *    in software this way:
+	 *
+	 *    Key[31:0], Stream[335:0]
+	 *
+	 *    tmp_key[11 * 32 - 1:0] = 11{Key[31:0] = key concatenated 11 times
+	 *    int_key[350:0] = tmp_key[351:1]
+	 *    int_stream[365:0] = Stream[14:0] | Stream[335:0] | Stream[335:321]
+	 *
+	 *    hash[15:0] = 0;
+	 *    for (i = 0; i < 351; i++) {
+	 *        if (int_key[i])
+	 *            hash ^= int_stream[(i + 15):i];
+	 *    }
+	 */
+
+	union {
+		u64    fill[6];
+		u32    key[11];
+		u8     key_stream[44];
+	} tmp_key;
+
+	u8   *stream = (u8 *)atr_input;
+	u8   int_key[44];      /* upper-most bit unused */
+	u8   hash_str[46];     /* upper-most 2 bits unused */
+	u16  hash_result = 0;
+	int  i, j, k, h;
+
+	/*
+	 * Initialize the fill member to prevent warnings
+	 * on some compilers
+	 */
+	 tmp_key.fill[0] = 0;
+
+	/* First load the temporary key stream */
+	for (i = 0; i < 6; i++) {
+		u64 fillkey = ((u64)key << 32) | key;
+		tmp_key.fill[i] = fillkey;
+	}
+
+	/*
+	 * Set the interim key for the hashing.  Bit 352 is unused, so we must
+	 * shift and compensate when building the key.
+	 */
+
+	int_key[0] = tmp_key.key_stream[0] >> 1;
+	for (i = 1, j = 0; i < 44; i++) {
+		unsigned int this_key = tmp_key.key_stream[j] << 7;
+		j++;
+		int_key[i] = (u8)(this_key | (tmp_key.key_stream[j] >> 1));
+	}
+
+	/*
+	 * Set the interim bit string for the hashing.  Bits 368 and 367 are
+	 * unused, so shift and compensate when building the string.
+	 */
+	hash_str[0] = (stream[40] & 0x7f) >> 1;
+	for (i = 1, j = 40; i < 46; i++) {
+		unsigned int this_str = stream[j] << 7;
+		j++;
+		if (j > 41)
+			j = 0;
+		hash_str[i] = (u8)(this_str | (stream[j] >> 1));
+	}
+
+	/*
+	 * Now compute the hash.  i is the index into hash_str, j is into our
+	 * key stream, k is counting the number of bits, and h interates within
+	 * each byte.
+	 */
+	for (i = 45, j = 43, k = 0; k < 351 && i >= 2 && j >= 0; i--, j--) {
+		for (h = 0; h < 8 && k < 351; h++, k++) {
+			if (int_key[j] & (1 << h)) {
+				/*
+				 * Key bit is set, XOR in the current 16-bit
+				 * string.  Example of processing:
+				 *    h = 0,
+				 *      tmp = (hash_str[i - 2] & 0 << 16) |
+				 *            (hash_str[i - 1] & 0xff << 8) |
+				 *            (hash_str[i] & 0xff >> 0)
+				 *      So tmp = hash_str[15 + k:k], since the
+				 *      i + 2 clause rolls off the 16-bit value
+				 *    h = 7,
+				 *      tmp = (hash_str[i - 2] & 0x7f << 9) |
+				 *            (hash_str[i - 1] & 0xff << 1) |
+				 *            (hash_str[i] & 0x80 >> 7)
+				 */
+				int tmp = (hash_str[i] >> h);
+				tmp |= (hash_str[i - 1] << (8 - h));
+				tmp |= (int)(hash_str[i - 2] & ((1 << h) - 1))
+				             << (16 - h);
+				hash_result ^= (u16)tmp;
+			}
+		}
+	}
+
+	return hash_result;
+}
+
+/**
+ *  ixgbe_atr_set_vlan_id_82599 - Sets the VLAN id in the ATR input stream
+ *  @input: input stream to modify
+ *  @vlan: the VLAN id to load
+ **/
+s32 ixgbe_atr_set_vlan_id_82599(struct ixgbe_atr_input *input, u16 vlan)
+{
+	input->byte_stream[IXGBE_ATR_VLAN_OFFSET + 1] = vlan >> 8;
+	input->byte_stream[IXGBE_ATR_VLAN_OFFSET] = vlan & 0xff;
+
+	return 0;
+}
+
+/**
+ *  ixgbe_atr_set_src_ipv4_82599 - Sets the source IPv4 address
+ *  @input: input stream to modify
+ *  @src_addr: the IP address to load
+ **/
+s32 ixgbe_atr_set_src_ipv4_82599(struct ixgbe_atr_input *input, u32 src_addr)
+{
+	input->byte_stream[IXGBE_ATR_SRC_IPV4_OFFSET + 3] = src_addr >> 24;
+	input->byte_stream[IXGBE_ATR_SRC_IPV4_OFFSET + 2] =
+	                                               (src_addr >> 16) & 0xff;
+	input->byte_stream[IXGBE_ATR_SRC_IPV4_OFFSET + 1] =
+	                                                (src_addr >> 8) & 0xff;
+	input->byte_stream[IXGBE_ATR_SRC_IPV4_OFFSET] = src_addr & 0xff;
+
+	return 0;
+}
+
+/**
+ *  ixgbe_atr_set_dst_ipv4_82599 - Sets the destination IPv4 address
+ *  @input: input stream to modify
+ *  @dst_addr: the IP address to load
+ **/
+s32 ixgbe_atr_set_dst_ipv4_82599(struct ixgbe_atr_input *input, u32 dst_addr)
+{
+	input->byte_stream[IXGBE_ATR_DST_IPV4_OFFSET + 3] = dst_addr >> 24;
+	input->byte_stream[IXGBE_ATR_DST_IPV4_OFFSET + 2] =
+	                                               (dst_addr >> 16) & 0xff;
+	input->byte_stream[IXGBE_ATR_DST_IPV4_OFFSET + 1] =
+	                                                (dst_addr >> 8) & 0xff;
+	input->byte_stream[IXGBE_ATR_DST_IPV4_OFFSET] = dst_addr & 0xff;
+
+	return 0;
+}
+
+/**
+ *  ixgbe_atr_set_src_ipv6_82599 - Sets the source IPv6 address
+ *  @input: input stream to modify
+ *  @src_addr_1: the first 4 bytes of the IP address to load
+ *  @src_addr_2: the second 4 bytes of the IP address to load
+ *  @src_addr_3: the third 4 bytes of the IP address to load
+ *  @src_addr_4: the fourth 4 bytes of the IP address to load
+ **/
+s32 ixgbe_atr_set_src_ipv6_82599(struct ixgbe_atr_input *input,
+                                 u32 src_addr_1, u32 src_addr_2,
+                                 u32 src_addr_3, u32 src_addr_4)
+{
+	input->byte_stream[IXGBE_ATR_SRC_IPV6_OFFSET] = src_addr_4 & 0xff;
+	input->byte_stream[IXGBE_ATR_SRC_IPV6_OFFSET + 1] =
+	                                               (src_addr_4 >> 8) & 0xff;
+	input->byte_stream[IXGBE_ATR_SRC_IPV6_OFFSET + 2] =
+	                                              (src_addr_4 >> 16) & 0xff;
+	input->byte_stream[IXGBE_ATR_SRC_IPV6_OFFSET + 3] = src_addr_4 >> 24;
+
+	input->byte_stream[IXGBE_ATR_SRC_IPV6_OFFSET + 4] = src_addr_3 & 0xff;
+	input->byte_stream[IXGBE_ATR_SRC_IPV6_OFFSET + 5] =
+	                                               (src_addr_3 >> 8) & 0xff;
+	input->byte_stream[IXGBE_ATR_SRC_IPV6_OFFSET + 6] =
+	                                              (src_addr_3 >> 16) & 0xff;
+	input->byte_stream[IXGBE_ATR_SRC_IPV6_OFFSET + 7] = src_addr_3 >> 24;
+
+	input->byte_stream[IXGBE_ATR_SRC_IPV6_OFFSET + 8] = src_addr_2 & 0xff;
+	input->byte_stream[IXGBE_ATR_SRC_IPV6_OFFSET + 9] =
+	                                               (src_addr_2 >> 8) & 0xff;
+	input->byte_stream[IXGBE_ATR_SRC_IPV6_OFFSET + 10] =
+	                                              (src_addr_2 >> 16) & 0xff;
+	input->byte_stream[IXGBE_ATR_SRC_IPV6_OFFSET + 11] = src_addr_2 >> 24;
+
+	input->byte_stream[IXGBE_ATR_SRC_IPV6_OFFSET + 12] = src_addr_1 & 0xff;
+	input->byte_stream[IXGBE_ATR_SRC_IPV6_OFFSET + 13] =
+	                                               (src_addr_1 >> 8) & 0xff;
+	input->byte_stream[IXGBE_ATR_SRC_IPV6_OFFSET + 14] =
+	                                              (src_addr_1 >> 16) & 0xff;
+	input->byte_stream[IXGBE_ATR_SRC_IPV6_OFFSET + 15] = src_addr_1 >> 24;
+
+	return 0;
+}
+
+/**
+ *  ixgbe_atr_set_dst_ipv6_82599 - Sets the destination IPv6 address
+ *  @input: input stream to modify
+ *  @dst_addr_1: the first 4 bytes of the IP address to load
+ *  @dst_addr_2: the second 4 bytes of the IP address to load
+ *  @dst_addr_3: the third 4 bytes of the IP address to load
+ *  @dst_addr_4: the fourth 4 bytes of the IP address to load
+ **/
+s32 ixgbe_atr_set_dst_ipv6_82599(struct ixgbe_atr_input *input,
+                                 u32 dst_addr_1, u32 dst_addr_2,
+                                 u32 dst_addr_3, u32 dst_addr_4)
+{
+	input->byte_stream[IXGBE_ATR_DST_IPV6_OFFSET] = dst_addr_4 & 0xff;
+	input->byte_stream[IXGBE_ATR_DST_IPV6_OFFSET + 1] =
+	                                               (dst_addr_4 >> 8) & 0xff;
+	input->byte_stream[IXGBE_ATR_DST_IPV6_OFFSET + 2] =
+	                                              (dst_addr_4 >> 16) & 0xff;
+	input->byte_stream[IXGBE_ATR_DST_IPV6_OFFSET + 3] = dst_addr_4 >> 24;
+
+	input->byte_stream[IXGBE_ATR_DST_IPV6_OFFSET + 4] = dst_addr_3 & 0xff;
+	input->byte_stream[IXGBE_ATR_DST_IPV6_OFFSET + 5] =
+	                                               (dst_addr_3 >> 8) & 0xff;
+	input->byte_stream[IXGBE_ATR_DST_IPV6_OFFSET + 6] =
+	                                              (dst_addr_3 >> 16) & 0xff;
+	input->byte_stream[IXGBE_ATR_DST_IPV6_OFFSET + 7] = dst_addr_3 >> 24;
+
+	input->byte_stream[IXGBE_ATR_DST_IPV6_OFFSET + 8] = dst_addr_2 & 0xff;
+	input->byte_stream[IXGBE_ATR_DST_IPV6_OFFSET + 9] =
+	                                               (dst_addr_2 >> 8) & 0xff;
+	input->byte_stream[IXGBE_ATR_DST_IPV6_OFFSET + 10] =
+	                                              (dst_addr_2 >> 16) & 0xff;
+	input->byte_stream[IXGBE_ATR_DST_IPV6_OFFSET + 11] = dst_addr_2 >> 24;
+
+	input->byte_stream[IXGBE_ATR_DST_IPV6_OFFSET + 12] = dst_addr_1 & 0xff;
+	input->byte_stream[IXGBE_ATR_DST_IPV6_OFFSET + 13] =
+	                                               (dst_addr_1 >> 8) & 0xff;
+	input->byte_stream[IXGBE_ATR_DST_IPV6_OFFSET + 14] =
+	                                              (dst_addr_1 >> 16) & 0xff;
+	input->byte_stream[IXGBE_ATR_DST_IPV6_OFFSET + 15] = dst_addr_1 >> 24;
+
+	return 0;
+}
+
+/**
+ *  ixgbe_atr_set_src_port_82599 - Sets the source port
+ *  @input: input stream to modify
+ *  @src_port: the source port to load
+ **/
+s32 ixgbe_atr_set_src_port_82599(struct ixgbe_atr_input *input, u16 src_port)
+{
+	input->byte_stream[IXGBE_ATR_SRC_PORT_OFFSET + 1] = src_port >> 8;
+	input->byte_stream[IXGBE_ATR_SRC_PORT_OFFSET] = src_port & 0xff;
+
+	return 0;
+}
+
+/**
+ *  ixgbe_atr_set_dst_port_82599 - Sets the destination port
+ *  @input: input stream to modify
+ *  @dst_port: the destination port to load
+ **/
+s32 ixgbe_atr_set_dst_port_82599(struct ixgbe_atr_input *input, u16 dst_port)
+{
+	input->byte_stream[IXGBE_ATR_DST_PORT_OFFSET + 1] = dst_port >> 8;
+	input->byte_stream[IXGBE_ATR_DST_PORT_OFFSET] = dst_port & 0xff;
+
+	return 0;
+}
+
+/**
+ *  ixgbe_atr_set_flex_byte_82599 - Sets the flexible bytes
+ *  @input: input stream to modify
+ *  @flex_bytes: the flexible bytes to load
+ **/
+s32 ixgbe_atr_set_flex_byte_82599(struct ixgbe_atr_input *input, u16 flex_byte)
+{
+	input->byte_stream[IXGBE_ATR_FLEX_BYTE_OFFSET + 1] = flex_byte >> 8;
+	input->byte_stream[IXGBE_ATR_FLEX_BYTE_OFFSET] = flex_byte & 0xff;
+
+	return 0;
+}
+
+/**
+ *  ixgbe_atr_set_vm_pool_82599 - Sets the Virtual Machine pool
+ *  @input: input stream to modify
+ *  @vm_pool: the Virtual Machine pool to load
+ **/
+s32 ixgbe_atr_set_vm_pool_82599(struct ixgbe_atr_input *input, u8 vm_pool)
+{
+	input->byte_stream[IXGBE_ATR_VM_POOL_OFFSET] = vm_pool;
+
+	return 0;
+}
+
+/**
+ *  ixgbe_atr_set_l4type_82599 - Sets the layer 4 packet type
+ *  @input: input stream to modify
+ *  @l4type: the layer 4 type value to load
+ **/
+s32 ixgbe_atr_set_l4type_82599(struct ixgbe_atr_input *input, u8 l4type)
+{
+	input->byte_stream[IXGBE_ATR_L4TYPE_OFFSET] = l4type;
+
+	return 0;
+}
+
+/**
+ *  ixgbe_atr_get_vlan_id_82599 - Gets the VLAN id from the ATR input stream
+ *  @input: input stream to search
+ *  @vlan: the VLAN id to load
+ **/
+s32 ixgbe_atr_get_vlan_id_82599(struct ixgbe_atr_input *input, u16 *vlan)
+{
+	*vlan = input->byte_stream[IXGBE_ATR_VLAN_OFFSET];
+	*vlan |= input->byte_stream[IXGBE_ATR_VLAN_OFFSET + 1] << 8;
+
+	return 0;
+}
+
+/**
+ *  ixgbe_atr_get_src_ipv4_82599 - Gets the source IPv4 address
+ *  @input: input stream to search
+ *  @src_addr: the IP address to load
+ **/
+s32 ixgbe_atr_get_src_ipv4_82599(struct ixgbe_atr_input *input, u32 *src_addr)
+{
+	*src_addr = input->byte_stream[IXGBE_ATR_SRC_IPV4_OFFSET];
+	*src_addr |= input->byte_stream[IXGBE_ATR_SRC_IPV4_OFFSET + 1] << 8;
+	*src_addr |= input->byte_stream[IXGBE_ATR_SRC_IPV4_OFFSET + 2] << 16;
+	*src_addr |= input->byte_stream[IXGBE_ATR_SRC_IPV4_OFFSET + 3] << 24;
+
+	return 0;
+}
+
+/**
+ *  ixgbe_atr_get_dst_ipv4_82599 - Gets the destination IPv4 address
+ *  @input: input stream to search
+ *  @dst_addr: the IP address to load
+ **/
+s32 ixgbe_atr_get_dst_ipv4_82599(struct ixgbe_atr_input *input, u32 *dst_addr)
+{
+	*dst_addr = input->byte_stream[IXGBE_ATR_DST_IPV4_OFFSET];
+	*dst_addr |= input->byte_stream[IXGBE_ATR_DST_IPV4_OFFSET + 1] << 8;
+	*dst_addr |= input->byte_stream[IXGBE_ATR_DST_IPV4_OFFSET + 2] << 16;
+	*dst_addr |= input->byte_stream[IXGBE_ATR_DST_IPV4_OFFSET + 3] << 24;
+
+	return 0;
+}
+
+/**
+ *  ixgbe_atr_get_src_ipv6_82599 - Gets the source IPv6 address
+ *  @input: input stream to search
+ *  @src_addr_1: the first 4 bytes of the IP address to load
+ *  @src_addr_2: the second 4 bytes of the IP address to load
+ *  @src_addr_3: the third 4 bytes of the IP address to load
+ *  @src_addr_4: the fourth 4 bytes of the IP address to load
+ **/
+s32 ixgbe_atr_get_src_ipv6_82599(struct ixgbe_atr_input *input,
+                                 u32 *src_addr_1, u32 *src_addr_2,
+                                 u32 *src_addr_3, u32 *src_addr_4)
+{
+	*src_addr_1 = input->byte_stream[IXGBE_ATR_SRC_IPV6_OFFSET + 12];
+	*src_addr_1 = input->byte_stream[IXGBE_ATR_SRC_IPV6_OFFSET + 13] << 8;
+	*src_addr_1 = input->byte_stream[IXGBE_ATR_SRC_IPV6_OFFSET + 14] << 16;
+	*src_addr_1 = input->byte_stream[IXGBE_ATR_SRC_IPV6_OFFSET + 15] << 24;
+
+	*src_addr_2 = input->byte_stream[IXGBE_ATR_SRC_IPV6_OFFSET + 8];
+	*src_addr_2 = input->byte_stream[IXGBE_ATR_SRC_IPV6_OFFSET + 9] << 8;
+	*src_addr_2 = input->byte_stream[IXGBE_ATR_SRC_IPV6_OFFSET + 10] << 16;
+	*src_addr_2 = input->byte_stream[IXGBE_ATR_SRC_IPV6_OFFSET + 11] << 24;
+
+	*src_addr_3 = input->byte_stream[IXGBE_ATR_SRC_IPV6_OFFSET + 4];
+	*src_addr_3 = input->byte_stream[IXGBE_ATR_SRC_IPV6_OFFSET + 5] << 8;
+	*src_addr_3 = input->byte_stream[IXGBE_ATR_SRC_IPV6_OFFSET + 6] << 16;
+	*src_addr_3 = input->byte_stream[IXGBE_ATR_SRC_IPV6_OFFSET + 7] << 24;
+
+	*src_addr_4 = input->byte_stream[IXGBE_ATR_SRC_IPV6_OFFSET];
+	*src_addr_4 = input->byte_stream[IXGBE_ATR_SRC_IPV6_OFFSET + 1] << 8;
+	*src_addr_4 = input->byte_stream[IXGBE_ATR_SRC_IPV6_OFFSET + 2] << 16;
+	*src_addr_4 = input->byte_stream[IXGBE_ATR_SRC_IPV6_OFFSET + 3] << 24;
+
+	return 0;
+}
+
+/**
+ *  ixgbe_atr_get_dst_ipv6_82599 - Gets the destination IPv6 address
+ *  @input: input stream to search
+ *  @dst_addr_1: the first 4 bytes of the IP address to load
+ *  @dst_addr_2: the second 4 bytes of the IP address to load
+ *  @dst_addr_3: the third 4 bytes of the IP address to load
+ *  @dst_addr_4: the fourth 4 bytes of the IP address to load
+ **/
+s32 ixgbe_atr_get_dst_ipv6_82599(struct ixgbe_atr_input *input,
+                                 u32 *dst_addr_1, u32 *dst_addr_2,
+                                 u32 *dst_addr_3, u32 *dst_addr_4)
+{
+	*dst_addr_1 = input->byte_stream[IXGBE_ATR_DST_IPV6_OFFSET + 12];
+	*dst_addr_1 = input->byte_stream[IXGBE_ATR_DST_IPV6_OFFSET + 13] << 8;
+	*dst_addr_1 = input->byte_stream[IXGBE_ATR_DST_IPV6_OFFSET + 14] << 16;
+	*dst_addr_1 = input->byte_stream[IXGBE_ATR_DST_IPV6_OFFSET + 15] << 24;
+
+	*dst_addr_2 = input->byte_stream[IXGBE_ATR_DST_IPV6_OFFSET + 8];
+	*dst_addr_2 = input->byte_stream[IXGBE_ATR_DST_IPV6_OFFSET + 9] << 8;
+	*dst_addr_2 = input->byte_stream[IXGBE_ATR_DST_IPV6_OFFSET + 10] << 16;
+	*dst_addr_2 = input->byte_stream[IXGBE_ATR_DST_IPV6_OFFSET + 11] << 24;
+
+	*dst_addr_3 = input->byte_stream[IXGBE_ATR_DST_IPV6_OFFSET + 4];
+	*dst_addr_3 = input->byte_stream[IXGBE_ATR_DST_IPV6_OFFSET + 5] << 8;
+	*dst_addr_3 = input->byte_stream[IXGBE_ATR_DST_IPV6_OFFSET + 6] << 16;
+	*dst_addr_3 = input->byte_stream[IXGBE_ATR_DST_IPV6_OFFSET + 7] << 24;
+
+	*dst_addr_4 = input->byte_stream[IXGBE_ATR_DST_IPV6_OFFSET];
+	*dst_addr_4 = input->byte_stream[IXGBE_ATR_DST_IPV6_OFFSET + 1] << 8;
+	*dst_addr_4 = input->byte_stream[IXGBE_ATR_DST_IPV6_OFFSET + 2] << 16;
+	*dst_addr_4 = input->byte_stream[IXGBE_ATR_DST_IPV6_OFFSET + 3] << 24;
+
+	return 0;
+}
+
+/**
+ *  ixgbe_atr_get_src_port_82599 - Gets the source port
+ *  @input: input stream to modify
+ *  @src_port: the source port to load
+ *
+ *  Even though the input is given in big-endian, the FDIRPORT registers
+ *  expect the ports to be programmed in little-endian.  Hence the need to swap
+ *  endianness when retrieving the data.  This can be confusing since the
+ *  internal hash engine expects it to be big-endian.
+ **/
+s32 ixgbe_atr_get_src_port_82599(struct ixgbe_atr_input *input, u16 *src_port)
+{
+	*src_port = input->byte_stream[IXGBE_ATR_SRC_PORT_OFFSET] << 8;
+	*src_port |= input->byte_stream[IXGBE_ATR_SRC_PORT_OFFSET + 1];
+
+	return 0;
+}
+
+/**
+ *  ixgbe_atr_get_dst_port_82599 - Gets the destination port
+ *  @input: input stream to modify
+ *  @dst_port: the destination port to load
+ *
+ *  Even though the input is given in big-endian, the FDIRPORT registers
+ *  expect the ports to be programmed in little-endian.  Hence the need to swap
+ *  endianness when retrieving the data.  This can be confusing since the
+ *  internal hash engine expects it to be big-endian.
+ **/
+s32 ixgbe_atr_get_dst_port_82599(struct ixgbe_atr_input *input, u16 *dst_port)
+{
+	*dst_port = input->byte_stream[IXGBE_ATR_DST_PORT_OFFSET] << 8;
+	*dst_port |= input->byte_stream[IXGBE_ATR_DST_PORT_OFFSET + 1];
+
+	return 0;
+}
+
+/**
+ *  ixgbe_atr_get_flex_byte_82599 - Gets the flexible bytes
+ *  @input: input stream to modify
+ *  @flex_bytes: the flexible bytes to load
+ **/
+s32 ixgbe_atr_get_flex_byte_82599(struct ixgbe_atr_input *input, u16 *flex_byte)
+{
+	*flex_byte = input->byte_stream[IXGBE_ATR_FLEX_BYTE_OFFSET];
+	*flex_byte |= input->byte_stream[IXGBE_ATR_FLEX_BYTE_OFFSET + 1] << 8;
+
+	return 0;
+}
+
+/**
+ *  ixgbe_atr_get_vm_pool_82599 - Gets the Virtual Machine pool
+ *  @input: input stream to modify
+ *  @vm_pool: the Virtual Machine pool to load
+ **/
+s32 ixgbe_atr_get_vm_pool_82599(struct ixgbe_atr_input *input, u8 *vm_pool)
+{
+	*vm_pool = input->byte_stream[IXGBE_ATR_VM_POOL_OFFSET];
+
+	return 0;
+}
+
+/**
+ *  ixgbe_atr_get_l4type_82599 - Gets the layer 4 packet type
+ *  @input: input stream to modify
+ *  @l4type: the layer 4 type value to load
+ **/
+s32 ixgbe_atr_get_l4type_82599(struct ixgbe_atr_input *input, u8 *l4type)
+{
+	*l4type = input->byte_stream[IXGBE_ATR_L4TYPE_OFFSET];
+
+	return 0;
+}
+
+/**
+ *  ixgbe_atr_add_signature_filter_82599 - Adds a signature hash filter
+ *  @hw: pointer to hardware structure
+ *  @stream: input bitstream
+ *  @queue: queue index to direct traffic to
+ **/
+s32 ixgbe_fdir_add_signature_filter_82599(struct ixgbe_hw *hw,
+                                          struct ixgbe_atr_input *input,
+                                          u8 queue)
+{
+	u64  fdirhashcmd;
+	u64  fdircmd;
+	u32  fdirhash;
+	u16  bucket_hash, sig_hash;
+	u8   l4type;
+
+	bucket_hash = ixgbe_atr_compute_hash_82599(input,
+	                                           IXGBE_ATR_BUCKET_HASH_KEY);
+
+	/* bucket_hash is only 15 bits */
+	bucket_hash &= IXGBE_ATR_HASH_MASK;
+
+	sig_hash = ixgbe_atr_compute_hash_82599(input,
+	                                        IXGBE_ATR_SIGNATURE_HASH_KEY);
+
+	/* Get the l4type in order to program FDIRCMD properly */
+	/* lowest 2 bits are FDIRCMD.L4TYPE, third lowest bit is FDIRCMD.IPV6 */
+	ixgbe_atr_get_l4type_82599(input, &l4type);
+
+	/*
+	 * The lower 32-bits of fdirhashcmd is for FDIRHASH, the upper 32-bits
+	 * is for FDIRCMD.  Then do a 64-bit register write from FDIRHASH.
+	 */
+	fdirhash = sig_hash << IXGBE_FDIRHASH_SIG_SW_INDEX_SHIFT | bucket_hash;
+
+	fdircmd = (IXGBE_FDIRCMD_CMD_ADD_FLOW | IXGBE_FDIRCMD_FILTER_UPDATE |
+	           IXGBE_FDIRCMD_LAST | IXGBE_FDIRCMD_QUEUE_EN);
+
+	switch (l4type & IXGBE_ATR_L4TYPE_MASK) {
+	case IXGBE_ATR_L4TYPE_TCP:
+		fdircmd |= IXGBE_FDIRCMD_L4TYPE_TCP;
+		break;
+	case IXGBE_ATR_L4TYPE_UDP:
+		fdircmd |= IXGBE_FDIRCMD_L4TYPE_UDP;
+		break;
+	case IXGBE_ATR_L4TYPE_SCTP:
+		fdircmd |= IXGBE_FDIRCMD_L4TYPE_SCTP;
+		break;
+	default:
+		hw_dbg(hw, "Error on l4type input\n");
+		return IXGBE_ERR_CONFIG;
+	}
+
+	if (l4type & IXGBE_ATR_L4TYPE_IPV6_MASK)
+		fdircmd |= IXGBE_FDIRCMD_IPV6;
+
+	fdircmd |= ((u64)queue << IXGBE_FDIRCMD_RX_QUEUE_SHIFT);
+	fdirhashcmd = ((fdircmd << 32) | fdirhash);
+
+	IXGBE_WRITE_REG64(hw, IXGBE_FDIRHASH, fdirhashcmd);
+
+	return 0;
+}
+
+/**
+ *  ixgbe_fdir_add_perfect_filter_82599 - Adds a perfect filter
+ *  @hw: pointer to hardware structure
+ *  @input: input bitstream
+ *  @queue: queue index to direct traffic to
+ *
+ *  Note that the caller to this function must lock before calling, since the
+ *  hardware writes must be protected from one another.
+ **/
+s32 ixgbe_fdir_add_perfect_filter_82599(struct ixgbe_hw *hw,
+                                        struct ixgbe_atr_input *input,
+                                        u16 soft_id,
+                                        u8 queue)
+{
+	u32 fdircmd = 0;
+	u32 fdirhash;
+	u32 src_ipv4, dst_ipv4;
+	u32 src_ipv6_1, src_ipv6_2, src_ipv6_3, src_ipv6_4;
+	u16 src_port, dst_port, vlan_id, flex_bytes;
+	u16 bucket_hash;
+	u8  l4type;
+
+	/* Get our input values */
+	ixgbe_atr_get_l4type_82599(input, &l4type);
+
+	/*
+	 * Check l4type formatting, and bail out before we touch the hardware
+	 * if there's a configuration issue
+	 */
+	switch (l4type & IXGBE_ATR_L4TYPE_MASK) {
+	case IXGBE_ATR_L4TYPE_TCP:
+		fdircmd |= IXGBE_FDIRCMD_L4TYPE_TCP;
+		break;
+	case IXGBE_ATR_L4TYPE_UDP:
+		fdircmd |= IXGBE_FDIRCMD_L4TYPE_UDP;
+		break;
+	case IXGBE_ATR_L4TYPE_SCTP:
+		fdircmd |= IXGBE_FDIRCMD_L4TYPE_SCTP;
+		break;
+	default:
+		hw_dbg(hw, "Error on l4type input\n");
+		return IXGBE_ERR_CONFIG;
+	}
+
+	bucket_hash = ixgbe_atr_compute_hash_82599(input,
+	                                           IXGBE_ATR_BUCKET_HASH_KEY);
+
+	/* bucket_hash is only 15 bits */
+	bucket_hash &= IXGBE_ATR_HASH_MASK;
+
+	ixgbe_atr_get_vlan_id_82599(input, &vlan_id);
+	ixgbe_atr_get_src_port_82599(input, &src_port);
+	ixgbe_atr_get_dst_port_82599(input, &dst_port);
+	ixgbe_atr_get_flex_byte_82599(input, &flex_bytes);
+
+	fdirhash = soft_id << IXGBE_FDIRHASH_SIG_SW_INDEX_SHIFT | bucket_hash;
+
+	/* Now figure out if we're IPv4 or IPv6 */
+	if (l4type & IXGBE_ATR_L4TYPE_IPV6_MASK) {
+		/* IPv6 */
+		ixgbe_atr_get_src_ipv6_82599(input, &src_ipv6_1, &src_ipv6_2,
+	                                     &src_ipv6_3, &src_ipv6_4);
+
+		IXGBE_WRITE_REG(hw, IXGBE_FDIRSIPv6(0), src_ipv6_1);
+		IXGBE_WRITE_REG(hw, IXGBE_FDIRSIPv6(1), src_ipv6_2);
+		IXGBE_WRITE_REG(hw, IXGBE_FDIRSIPv6(2), src_ipv6_3);
+		/* The last 4 bytes is the same register as IPv4 */
+		IXGBE_WRITE_REG(hw, IXGBE_FDIRIPSA, src_ipv6_4);
+
+		fdircmd |= IXGBE_FDIRCMD_IPV6;
+		fdircmd |= IXGBE_FDIRCMD_IPv6DMATCH;
+	} else {
+		/* IPv4 */
+		ixgbe_atr_get_src_ipv4_82599(input, &src_ipv4);
+		IXGBE_WRITE_REG(hw, IXGBE_FDIRIPSA, src_ipv4);
+
+	}
+
+	ixgbe_atr_get_dst_ipv4_82599(input, &dst_ipv4);
+	IXGBE_WRITE_REG(hw, IXGBE_FDIRIPDA, dst_ipv4);
+
+	IXGBE_WRITE_REG(hw, IXGBE_FDIRVLAN, (vlan_id |
+	                            (flex_bytes << IXGBE_FDIRVLAN_FLEX_SHIFT)));
+	IXGBE_WRITE_REG(hw, IXGBE_FDIRPORT, (src_port |
+	                       (dst_port << IXGBE_FDIRPORT_DESTINATION_SHIFT)));
+
+	fdircmd |= IXGBE_FDIRCMD_CMD_ADD_FLOW;
+	fdircmd |= IXGBE_FDIRCMD_FILTER_UPDATE;
+	fdircmd |= IXGBE_FDIRCMD_LAST;
+	fdircmd |= IXGBE_FDIRCMD_QUEUE_EN;
+	fdircmd |= queue << IXGBE_FDIRCMD_RX_QUEUE_SHIFT;
+
+	IXGBE_WRITE_REG(hw, IXGBE_FDIRHASH, fdirhash);
+	IXGBE_WRITE_REG(hw, IXGBE_FDIRCMD, fdircmd);
+
+	return 0;
+}
+/**
  *  ixgbe_read_analog_reg8_82599 - Reads 8 bit Omer analog register
  *  @hw: pointer to hardware structure
  *  @reg: analog register to read

