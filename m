From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 15/16] ixgbe: cleanup ixgbe_init_mbx_params_pf namespace issue
Date: Tue,  8 Feb 2011 04:29:26 -0800
Message-ID: <1297168167-15755-16-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1297168167-15755-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:60568 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751544Ab1BHM3l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Feb 2011 07:29:41 -0500
In-Reply-To: <1297168167-15755-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

The function ixgbe_init_mbx_params_pf isn't used unless CONFIG_PCI_IOV
is defined.  This is causing namespace warnings.  So I wrapped its
definition in CONFIG_PCI_IOV too.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_mbx.c |    2 ++
 drivers/net/ixgbe/ixgbe_mbx.h |    2 ++
 2 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_mbx.c b/drivers/net/ixgbe/ixgbe_mbx.c
index ea82c5a..f215c4c 100644
--- a/drivers/net/ixgbe/ixgbe_mbx.c
+++ b/drivers/net/ixgbe/ixgbe_mbx.c
@@ -437,6 +437,7 @@ out_no_read:
 	return ret_val;
 }
 
+#ifdef CONFIG_PCI_IOV
 /**
  *  ixgbe_init_mbx_params_pf - set initial values for pf mailbox
  *  @hw: pointer to the HW structure
@@ -465,6 +466,7 @@ void ixgbe_init_mbx_params_pf(struct ixgbe_hw *hw)
 		break;
 	}
 }
+#endif /* CONFIG_PCI_IOV */
 
 struct ixgbe_mbx_operations mbx_ops_generic = {
 	.read                   = ixgbe_read_mbx_pf,
diff --git a/drivers/net/ixgbe/ixgbe_mbx.h b/drivers/net/ixgbe/ixgbe_mbx.h
index 3df9b15..ada0ce3 100644
--- a/drivers/net/ixgbe/ixgbe_mbx.h
+++ b/drivers/net/ixgbe/ixgbe_mbx.h
@@ -86,7 +86,9 @@ s32 ixgbe_write_mbx(struct ixgbe_hw *, u32 *, u16, u16);
 s32 ixgbe_check_for_msg(struct ixgbe_hw *, u16);
 s32 ixgbe_check_for_ack(struct ixgbe_hw *, u16);
 s32 ixgbe_check_for_rst(struct ixgbe_hw *, u16);
+#ifdef CONFIG_PCI_IOV
 void ixgbe_init_mbx_params_pf(struct ixgbe_hw *);
+#endif /* CONFIG_PCI_IOV */
 
 extern struct ixgbe_mbx_operations mbx_ops_generic;
 
-- 
1.7.4

