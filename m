From: Tom Herbert <therbert@google.com>
Subject: [PATCH 3/4] rps: Infrastructure in __skb_get_rxhash for deep
 inspection
Date: Thu, 19 May 2011 08:39:21 -0700 (PDT)
Message-ID: <alpine.DEB.2.00.1105190828001.12835@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:35910 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755423Ab1ESPj2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 11:39:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Basics for looking for ports in encapsulated packets in tunnels.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/core/dev.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 37ddece..0c83494 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -133,6 +133,7 @@
 #include <linux/pci.h>
 #include <linux/inetdevice.h>
 #include <linux/cpu_rmap.h>
+#include <linux/if_tunnel.h>
 
 #include "net-sysfs.h"
 
@@ -2521,6 +2522,7 @@ void __skb_get_rxhash(struct sk_buff *skb)
 	nhoff = skb_network_offset(skb);
 	proto = skb->protocol;
 
+again:
 	switch (proto) {
 	case __constant_htons(ETH_P_IP):
 		if (!pskb_may_pull(skb, sizeof(*ip) + nhoff))
@@ -2549,6 +2551,11 @@ void __skb_get_rxhash(struct sk_buff *skb)
 		goto done;
 	}
 
+	switch (ip_proto) {
+	default:
+		break;
+	}
+
 	ports.v32 = 0;
 	poff = proto_ports_offset(ip_proto);
 	if (poff >= 0) {
-- 
1.7.3.1

