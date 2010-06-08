From: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Subject: [RFC PATCH 2/5] napi: convert trace_napi_poll to TRACE_EVENT
Date: Tue, 08 Jun 2010 14:28:59 +0900
Message-ID: <4C0DD51B.8020403@jp.fujitsu.com>
References: <4C0DD43F.9090902@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kaneshige.kenji@jp.fujitsu.com,
	izumi.taku@jp.fujitsu.com, nhorman@tuxdriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail6.fujitsu.co.jp ([192.51.44.36]:60712 "EHLO
	fgwmail6.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752097Ab0FHF2u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jun 2010 01:28:50 -0400
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o585SnrY016456
	for <netdev@vger.kernel.org> (envelope-from sanagi.koki@jp.fujitsu.com);
	Tue, 8 Jun 2010 14:28:49 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id D1EC245DE4D
	for <netdev@vger.kernel.org>; Tue,  8 Jun 2010 14:28:48 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A1D0245DE50
	for <netdev@vger.kernel.org>; Tue,  8 Jun 2010 14:28:48 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 72777E18003
	for <netdev@vger.kernel.org>; Tue,  8 Jun 2010 14:28:48 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 12B011DB8042
	for <netdev@vger.kernel.org>; Tue,  8 Jun 2010 14:28:48 +0900 (JST)
In-Reply-To: <4C0DD43F.9090902@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch converts trace_napi_poll from DECLARE_EVENT to TRACE_EVENT.
This is a same patch Neil Horman submitted.
http://marc.info/?l=linux-kernel&m=125978157926853&w=2

Signed-off-by: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
---
 include/trace/events/napi.h |   23 +++++++++++++++++++++--
 1 files changed, 21 insertions(+), 2 deletions(-)

diff --git a/include/trace/events/napi.h b/include/trace/events/napi.h
index 188deca..512a057 100644
--- a/include/trace/events/napi.h
+++ b/include/trace/events/napi.h
@@ -6,10 +6,29 @@
 
 #include <linux/netdevice.h>
 #include <linux/tracepoint.h>
+#include <linux/ftrace.h>
+
+#define NO_DEV "(no_device)"
+
+TRACE_EVENT(napi_poll,
 
-DECLARE_TRACE(napi_poll,
 	TP_PROTO(struct napi_struct *napi),
-	TP_ARGS(napi));
+
+	TP_ARGS(napi),
+
+	TP_STRUCT__entry(
+		__field(	struct napi_struct *,	napi)
+		__string(	dev_name, napi->dev ? napi->dev->name : NO_DEV)
+	),
+
+	TP_fast_assign(
+		__entry->napi = napi;
+		__assign_str(dev_name, napi->dev ? napi->dev->name : NO_DEV);
+	),
+
+	TP_printk("napi poll on napi struct %p for device %s",
+		__entry->napi, __get_str(dev_name))
+);
 
 #endif /* _TRACE_NAPI_H_ */
 


