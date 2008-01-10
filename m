From: Dzianis Kahanovich <mahatma@bspu.unibel.by>
Subject: [PATCH 2.6.23+] ingress classify to [nf]mark
Date: Thu, 10 Jan 2008 17:05:13 -0200
Message-ID: <47866C69.3080904@bspu.unibel.by>
Reply-To: mahatma@eu.by
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bspu.unibel.by ([195.50.2.21]:44522 "EHLO
	mail.bspu.unibel.by" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756017AbYAJRbD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2008 12:31:03 -0500
Received: from [10.200.200.1] ([10.200.200.1])
	by mail.bspu.unibel.by (8.14.1/8.14.0) with ESMTP id m0AF5MvL001841
	for <netdev@vger.kernel.org>; Thu, 10 Jan 2008 17:05:28 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To "classid x:y" = "mark=mark&x|y" ("classid :y" = "-j MARK --set-mark y", etc).

--- linux-2.6.23-gentoo-r2/net/sched/Kconfig
+++ linux-2.6.23-gentoo-r2.fixed/net/sched/Kconfig
@@ -222,6 +222,16 @@
  	  To compile this code as a module, choose M here: the
  	  module will be called sch_ingress.

+config NET_SCH_INGRESS_TC2MARK
+	bool "ingress classify -> mark"
+	depends on NET_SCH_INGRESS && NET_CLS_ACT
+	---help---
+	  This enables access to "mark" value via "classid"
+	  Example: set "tc filter ... flowid|classid 1:2"
+	  eq "netfilter mark" mark=mark&1|2
+	
+	  But classid may be undefined (?) - use "flowid :0".
+
  comment "Classification"

  config NET_CLS
--- linux-2.6.23-gentoo-r2/net/sched/sch_ingress.c
+++ linux-2.6.23-gentoo-r2.fixed/net/sched/sch_ingress.c
@@ -161,2 +161,5 @@
  			skb->tc_index = TC_H_MIN(res.classid);
+#ifdef CONFIG_NET_SCH_INGRESS_TC2MARK
+			skb->mark = (skb->mark&(res.classid>>16))|TC_H_MIN(res.classid);
+#endif
  		default:


-- 
WBR,
Denis Kaganovich,  mahatma@eu.by  http://mahatma.bspu.unibel.by
