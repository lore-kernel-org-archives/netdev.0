From: Shreyas Bhatewara <sbhatewara@vmware.com>
Subject: [PATCH] vmxnet3: Fix transport header size
Date: Wed, 29 Feb 2012 00:17:38 -0800 (PST)
Message-ID: <alpine.LRH.2.00.1202290015300.19873@sbhatewara-dev1.eng.vmware.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: pv-drivers@vmware.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-2.vmware.com ([208.91.2.13]:32998 "EHLO
	smtp-outbound-2.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751051Ab2B2IRi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Feb 2012 03:17:38 -0500
Received: from sc9-mailhost2.vmware.com (sc9-mailhost2.vmware.com [10.113.161.72])
	by smtp-outbound-2.vmware.com (Postfix) with ESMTP id 35D7B282A5
	for <netdev@vger.kernel.org>; Wed, 29 Feb 2012 00:17:38 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix transport header size

Fix the transpoert header size for UDP packets.

Signed-off-by: Shreyas N Bhatewara <sbhatewara@vmware.com>
---
diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index 6995d3c..522d9bc 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -830,13 +830,8 @@ vmxnet3_parse_and_copy_hdr(struct sk_buff *skb, struct vmxnet3_tx_queue *tq,
 					ctx->l4_hdr_size = ((struct tcphdr *)
 					   skb_transport_header(skb))->doff * 4;
 				else if (iph->protocol == IPPROTO_UDP)
-					/*
-					 * Use tcp header size so that bytes to
-					 * be copied are more than required by
-					 * the device.
-					 */
 					ctx->l4_hdr_size =
-							sizeof(struct tcphdr);
+							sizeof(struct udphdr);
 				else
 					ctx->l4_hdr_size = 0;
 			} else {
diff --git a/drivers/net/vmxnet3/vmxnet3_int.h b/drivers/net/vmxnet3/vmxnet3_int.h
index ed54797..fc46a81 100644
--- a/drivers/net/vmxnet3/vmxnet3_int.h
+++ b/drivers/net/vmxnet3/vmxnet3_int.h
@@ -70,10 +70,10 @@
 /*
  * Version numbers
  */
-#define VMXNET3_DRIVER_VERSION_STRING   "1.1.18.0-k"
+#define VMXNET3_DRIVER_VERSION_STRING   "1.1.29.0-k"
 
 /* a 32-bit int, each byte encode a verion number in VMXNET3_DRIVER_VERSION */
-#define VMXNET3_DRIVER_VERSION_NUM      0x01011200
+#define VMXNET3_DRIVER_VERSION_NUM      0x01011D00
 
 #if defined(CONFIG_PCI_MSI)
 	/* RSS only makes sense if MSI-X is supported. */
