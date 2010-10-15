From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next] vmxnet3: make bit twiddle routines inline
Date: Fri, 15 Oct 2010 14:06:20 -0700
Message-ID: <20101015140620.63d0a615@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "VMware, Inc." <pv-drivers@vmware.com>, netdev@vger.kernel.org
To: Shreyas Bhatewara <sbhatewara@vmware.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:55333 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755970Ab0JOVGX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Oct 2010 17:06:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gcc doesn't usually handle inline across compilation units, and the
functions don't have to be global in scope. Move the set/reset flag
functions int the existing vmxnet3 header.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 drivers/net/vmxnet3/vmxnet3_drv.c |   17 -----------------
 drivers/net/vmxnet3/vmxnet3_int.h |   17 ++++++++++++++---
 2 files changed, 14 insertions(+), 20 deletions(-)

--- a/drivers/net/vmxnet3/vmxnet3_drv.c	2010-10-15 13:58:23.378722695 -0700
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c	2010-10-15 13:59:32.724873755 -0700
@@ -1548,23 +1548,6 @@ vmxnet3_free_irqs(struct vmxnet3_adapter
 	}
 }
 
-
-inline void set_flag_le16(__le16 *data, u16 flag)
-{
-	*data = cpu_to_le16(le16_to_cpu(*data) | flag);
-}
-
-inline void set_flag_le64(__le64 *data, u64 flag)
-{
-	*data = cpu_to_le64(le64_to_cpu(*data) | flag);
-}
-
-inline void reset_flag_le64(__le64 *data, u64 flag)
-{
-	*data = cpu_to_le64(le64_to_cpu(*data) & ~flag);
-}
-
-
 static void
 vmxnet3_vlan_rx_register(struct net_device *netdev, struct vlan_group *grp)
 {
--- a/drivers/net/vmxnet3/vmxnet3_int.h	2010-10-15 13:58:23.390723065 -0700
+++ b/drivers/net/vmxnet3/vmxnet3_int.h	2010-10-15 13:59:46.329296549 -0700
@@ -353,9 +353,20 @@ struct vmxnet3_adapter {
 #define VMXNET3_MAX_ETH_HDR_SIZE    22
 #define VMXNET3_MAX_SKB_BUF_SIZE    (3*1024)
 
-void set_flag_le16(__le16 *data, u16 flag);
-void set_flag_le64(__le64 *data, u64 flag);
-void reset_flag_le64(__le64 *data, u64 flag);
+static inline void set_flag_le16(__le16 *data, u16 flag)
+{
+	*data = cpu_to_le16(le16_to_cpu(*data) | flag);
+}
+
+static inline void set_flag_le64(__le64 *data, u64 flag)
+{
+	*data = cpu_to_le64(le64_to_cpu(*data) | flag);
+}
+
+static inline void reset_flag_le64(__le64 *data, u64 flag)
+{
+	*data = cpu_to_le64(le64_to_cpu(*data) & ~flag);
+}
 
 int
 vmxnet3_quiesce_dev(struct vmxnet3_adapter *adapter);
