From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next ] i40evf: Rename i40e_ptype_lookup i40evf_ptype_lookup
Date: Fri, 14 Mar 2014 16:03:06 -0700
Message-ID: <87k3bw2xjp.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Catherine Sullivan <catherine.sullivan@intel.com>,
	Kavindya Deegala <kavindya.s.deegala@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:32860 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752030AbaCNXDO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 19:03:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


When compiling the i40e and the i40evf driver into the same kernel I get:
LD      drivers/net/ethernet/intel/built-in.o
drivers/net/ethernet/intel/i40evf/built-in.o:(.data+0x300): multiple definition of `i40e_ptype_lookup'
drivers/net/ethernet/intel/i40e/built-in.o:(.data+0x780): first defined here
make[3]: *** [drivers/net/ethernet/intel/built-in.o] Error 1
make[2]: *** [drivers/net/ethernet/intel] Error 2
make[1]: *** [drivers/net/ethernet/] Error 2
make: *** [sub-make] Error 2

Fix this by renaming the i40evf version of this structure from
i40e_ptype_lookup to i40evf_ptype_lookup.

This build failure was introduced in:
commit 206812b5fccb808d1194344eaa942f68f59b2630
Author: Jesse Brandeburg <jesse.brandeburg@intel.com>
Date:   Wed Feb 12 01:45:33 2014 +0000

    i40e/i40evf: i40e implementation for skb_set_hash

    Original comment from Tom Herbert <therbert@google.com>

       Drivers should call skb_set_hash to set the hash and its type
       in an skbuff.

    This patch builds upon Tom's original implementation and adds
    the L4 type return when we know it is an L4 hash.
    This requires use of the ptype decoder ring, so enable it.

    Change-ID: I2f9fa86d1a6add58cff13386f7f4238b1abcc468
    CC: Tom Herbert <therbert@google.com>
    Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
    Acked-by: Shannon Nelson <shannon.nelson@intel.com>
    Acked-by: Mitch Williams <mitch.a.williams@intel.com>
    Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
    Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
    Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
Cc: Catherine Sullivan <catherine.sullivan@intel.com>
Cc: Kavindya Deegala <kavindya.s.deegala@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/net/ethernet/intel/i40evf/i40e_common.c    |    8 ++++----
 drivers/net/ethernet/intel/i40evf/i40e_prototype.h |    4 ++--
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40e_common.c b/drivers/net/ethernet/intel/i40evf/i40e_common.c
index 78618af271cf..c688a0fc5c29 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_common.c
@@ -160,7 +160,7 @@ i40e_status i40evf_aq_queue_shutdown(struct i40e_hw *hw,
 }
 
 
-/* The i40e_ptype_lookup table is used to convert from the 8-bit ptype in the
+/* The i40evf_ptype_lookup table is used to convert from the 8-bit ptype in the
  * hardware to a bit-field that can be used by SW to more easily determine the
  * packet type.
  *
@@ -173,10 +173,10 @@ i40e_status i40evf_aq_queue_shutdown(struct i40e_hw *hw,
  *
  * Typical work flow:
  *
- * IF NOT i40e_ptype_lookup[ptype].known
+ * IF NOT i40evf_ptype_lookup[ptype].known
  * THEN
  *      Packet is unknown
- * ELSE IF i40e_ptype_lookup[ptype].outer_ip == I40E_RX_PTYPE_OUTER_IP
+ * ELSE IF i40evf_ptype_lookup[ptype].outer_ip == I40E_RX_PTYPE_OUTER_IP
  *      Use the rest of the fields to look at the tunnels, inner protocols, etc
  * ELSE
  *      Use the enum i40e_rx_l2_ptype to decode the packet type
@@ -205,7 +205,7 @@ i40e_status i40evf_aq_queue_shutdown(struct i40e_hw *hw,
 #define I40E_RX_PTYPE_INNER_PROT_TS	I40E_RX_PTYPE_INNER_PROT_TIMESYNC
 
 /* Lookup table mapping the HW PTYPE to the bit field for decoding */
-struct i40e_rx_ptype_decoded i40e_ptype_lookup[] = {
+struct i40e_rx_ptype_decoded i40evf_ptype_lookup[] = {
 	/* L2 Packet types */
 	I40E_PTT_UNUSED_ENTRY(0),
 	I40E_PTT(1,  L2, NONE, NOF, NONE, NONE, NOF, NONE, PAY2),
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_prototype.h b/drivers/net/ethernet/intel/i40evf/i40e_prototype.h
index 33c99051cc96..862fcdf52675 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_prototype.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_prototype.h
@@ -63,11 +63,11 @@ i40e_status i40evf_aq_queue_shutdown(struct i40e_hw *hw,
 
 i40e_status i40e_set_mac_type(struct i40e_hw *hw);
 
-extern struct i40e_rx_ptype_decoded i40e_ptype_lookup[];
+extern struct i40e_rx_ptype_decoded i40evf_ptype_lookup[];
 
 static inline struct i40e_rx_ptype_decoded decode_rx_desc_ptype(u8 ptype)
 {
-	return  i40e_ptype_lookup[ptype];
+	return  i40evf_ptype_lookup[ptype];
 }
 
 /* prototype for functions used for SW locks */
-- 
1.7.5.4
