From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: [PATCH 2/4] e1000e: Use marco instead of digit for defining e1000_rx_desc_packet_split
Date: Mon, 20 May 2013 16:15:05 +0800
Message-ID: <1369037707-27026-3-git-send-email-weiyang@linux.vnet.ibm.com>
References: <1369037707-27026-1-git-send-email-weiyang@linux.vnet.ibm.com>
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Wei Yang <weiyang@linux.vnet.ibm.com>
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp03.au.ibm.com ([202.81.31.145]:44670 "EHLO
	e23smtp03.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755278Ab3ETIPb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 May 2013 04:15:31 -0400
Received: from /spool/local
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <weiyang@linux.vnet.ibm.com>;
	Mon, 20 May 2013 18:07:00 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id E19BA2BB0023
	for <netdev@vger.kernel.org>; Mon, 20 May 2013 18:15:23 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4K8FG6h20644044
	for <netdev@vger.kernel.org>; Mon, 20 May 2013 18:15:16 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4K8FMkO019807
	for <netdev@vger.kernel.org>; Mon, 20 May 2013 18:15:23 +1000
In-Reply-To: <1369037707-27026-1-git-send-email-weiyang@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In structure e1000_rx_desc_packet_split, the size of wb.upper.length is
defined by a digit. This may introduce some problem when the lenght is
changed.

This patch use the marco PS_PAGE_BUFFERS for the definition. And move the
definition to hw.h.

Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
---
 drivers/net/ethernet/intel/e1000e/e1000.h |    3 ---
 drivers/net/ethernet/intel/e1000e/hw.h    |    5 ++++-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/e1000.h b/drivers/net/ethernet/intel/e1000e/e1000.h
index fcc7581..3ba560d 100644
--- a/drivers/net/ethernet/intel/e1000e/e1000.h
+++ b/drivers/net/ethernet/intel/e1000e/e1000.h
@@ -90,9 +90,6 @@ struct e1000_info;
 
 #define E1000_MNG_VLAN_NONE		(-1)
 
-/* Number of packet split data buffers (not including the header buffer) */
-#define PS_PAGE_BUFFERS			(MAX_PS_BUFFERS - 1)
-
 #define DEFAULT_JUMBO			9234
 
 /* Time to wait before putting the device into D3 if there's no link (in ms). */
diff --git a/drivers/net/ethernet/intel/e1000e/hw.h b/drivers/net/ethernet/intel/e1000e/hw.h
index 1e6b889..edc618ad 100644
--- a/drivers/net/ethernet/intel/e1000e/hw.h
+++ b/drivers/net/ethernet/intel/e1000e/hw.h
@@ -227,6 +227,9 @@ union e1000_rx_desc_extended {
 };
 
 #define MAX_PS_BUFFERS 4
+
+/* Number of packet split data buffers (not including the header buffer) */
+#define PS_PAGE_BUFFERS			(MAX_PS_BUFFERS - 1)
 /* Receive Descriptor - Packet Split */
 union e1000_rx_desc_packet_split {
 	struct {
@@ -251,7 +254,7 @@ union e1000_rx_desc_packet_split {
 		} middle;
 		struct {
 			__le16 header_status;
-			__le16 length[3];	/* length of buffers 1-3 */
+			__le16 length[PS_PAGE_BUFFERS];	/* length of buffers 1-3 */
 		} upper;
 		__le64 reserved;
 	} wb; /* writeback */
-- 
1.7.5.4
