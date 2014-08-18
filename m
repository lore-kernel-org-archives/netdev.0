From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net 2/3] qlcnic: Fix endianess issue in FW dump template header
Date: Mon, 18 Aug 2014 09:31:54 -0400
Message-ID: <1408368715-8048-3-git-send-email-shahed.shaikh@qlogic.com>
References: <1408368715-8048-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:10079 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751714AbaHROEc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2014 10:04:32 -0400
In-Reply-To: <1408368715-8048-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rajesh Borundia <rajesh.borundia@qlogic.com>

Firmware dump template header is read from adapter using
readl() which swaps the data. So, adjust structure
element on the boundary of 32bit dword.

Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 .../net/ethernet/qlogic/qlcnic/qlcnic_minidump.c   |   57 ++++++++++++++++++++
 1 files changed, 57 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c
index e46fc39..c9f57fb 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c
@@ -47,15 +47,26 @@ struct qlcnic_common_entry_hdr {
 	u32     type;
 	u32     offset;
 	u32     cap_size;
+#if defined(__LITTLE_ENDIAN)
 	u8      mask;
 	u8      rsvd[2];
 	u8      flags;
+#else
+	u8      flags;
+	u8      rsvd[2];
+	u8      mask;
+#endif
 } __packed;
 
 struct __crb {
 	u32	addr;
+#if defined(__LITTLE_ENDIAN)
 	u8	stride;
 	u8	rsvd1[3];
+#else
+	u8	rsvd1[3];
+	u8	stride;
+#endif
 	u32	data_size;
 	u32	no_ops;
 	u32	rsvd2[4];
@@ -63,15 +74,28 @@ struct __crb {
 
 struct __ctrl {
 	u32	addr;
+#if defined(__LITTLE_ENDIAN)
 	u8	stride;
 	u8	index_a;
 	u16	timeout;
+#else
+	u16	timeout;
+	u8	index_a;
+	u8	stride;
+#endif
 	u32	data_size;
 	u32	no_ops;
+#if defined(__LITTLE_ENDIAN)
 	u8	opcode;
 	u8	index_v;
 	u8	shl_val;
 	u8	shr_val;
+#else
+	u8	shr_val;
+	u8	shl_val;
+	u8	index_v;
+	u8	opcode;
+#endif
 	u32	val1;
 	u32	val2;
 	u32	val3;
@@ -79,16 +103,27 @@ struct __ctrl {
 
 struct __cache {
 	u32	addr;
+#if defined(__LITTLE_ENDIAN)
 	u16	stride;
 	u16	init_tag_val;
+#else
+	u16	init_tag_val;
+	u16	stride;
+#endif
 	u32	size;
 	u32	no_ops;
 	u32	ctrl_addr;
 	u32	ctrl_val;
 	u32	read_addr;
+#if defined(__LITTLE_ENDIAN)
 	u8	read_addr_stride;
 	u8	read_addr_num;
 	u8	rsvd1[2];
+#else
+	u8	rsvd1[2];
+	u8	read_addr_num;
+	u8	read_addr_stride;
+#endif
 } __packed;
 
 struct __ocm {
@@ -122,23 +157,39 @@ struct __mux {
 
 struct __queue {
 	u32	sel_addr;
+#if defined(__LITTLE_ENDIAN)
 	u16	stride;
 	u8	rsvd[2];
+#else
+	u8	rsvd[2];
+	u16	stride;
+#endif
 	u32	size;
 	u32	no_ops;
 	u8	rsvd2[8];
 	u32	read_addr;
+#if defined(__LITTLE_ENDIAN)
 	u8	read_addr_stride;
 	u8	read_addr_cnt;
 	u8	rsvd3[2];
+#else
+	u8	rsvd3[2];
+	u8	read_addr_cnt;
+	u8	read_addr_stride;
+#endif
 } __packed;
 
 struct __pollrd {
 	u32	sel_addr;
 	u32	read_addr;
 	u32	sel_val;
+#if defined(__LITTLE_ENDIAN)
 	u16	sel_val_stride;
 	u16	no_ops;
+#else
+	u16	no_ops;
+	u16	sel_val_stride;
+#endif
 	u32	poll_wait;
 	u32	poll_mask;
 	u32	data_size;
@@ -153,9 +204,15 @@ struct __mux2 {
 	u32	no_ops;
 	u32	sel_val_mask;
 	u32	read_addr;
+#if defined(__LITTLE_ENDIAN)
 	u8	sel_val_stride;
 	u8	data_size;
 	u8	rsvd[2];
+#else
+	u8	rsvd[2];
+	u8	data_size;
+	u8	sel_val_stride;
+#endif
 } __packed;
 
 struct __pollrdmwr {
-- 
1.5.6
