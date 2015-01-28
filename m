From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] act_connmark: fix dependencies better
Date: Wed, 28 Jan 2015 17:30:09 +0100
Message-ID: <1806649.OoZh1UV3MM@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Thomas Graf <tgraf@suug.ch>, Felix Fietkau <nbd@openwrt.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.131]:58192 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753749AbbA1Uyk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2015 15:54:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NET_ACT_CONNMARK fails to build if NF_CONNTRACK_MARK is disabled,
and d7924450e14ea4 ("act_connmark: Add missing dependency on
NF_CONNTRACK_MARK") fixed that case, but missed the cased where
NF_CONNTRACK is a loadable module.

This adds the second dependency to ensure that NET_ACT_CONNMARK
can only be built-in if NF_CONNTRACK is also part of the kernel
rather than a loadable module.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>

diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index 5fd81031f8f6..2264b491383a 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -713,7 +713,7 @@ config NET_ACT_BPF
 config NET_ACT_CONNMARK
         tristate "Netfilter Connection Mark Retriever"
         depends on NET_CLS_ACT && NETFILTER && IP_NF_IPTABLES
-        depends on NF_CONNTRACK_MARK
+        depends on NF_CONNTRACK && NF_CONNTRACK_MARK
         ---help---
 	  Say Y here to allow retrieving of conn mark
 
