From: Cyrill Gorcunov <gorcunov@openvz.org>
Subject: [patch 2/2] net, netns_xt: shrink netns_xt members
Date: Sat, 04 Jul 2009 10:11:58 +0400
Message-ID: <20090704062321.034802084@openvz.org>
References: <20090704061156.658235360@openvz.org>
Cc: Cyrill Gorcunov <gorcunov@openvz.org>
To: shemminger@linux-foundation.org, kaber@trash.net,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f207.google.com ([209.85.218.207]:64536 "EHLO
	mail-bw0-f207.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751281AbZGDG2V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jul 2009 02:28:21 -0400
Received: by bwz3 with SMTP id 3so714060bwz.37
        for <netdev@vger.kernel.org>; Fri, 03 Jul 2009 23:28:23 -0700 (PDT)
Content-Disposition: inline; filename=net-br-x-tables-ifconfig
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case if kernel was compiled without ebtables support
there is no need to keep ebt_table pointers in netns_xt
structure.

Make it config dependent.

Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
---

Probably GCC will authomatically shrink the structure
if the members are not in use. Please review.

 include/net/netns/x_tables.h |    3 +++
 1 file changed, 3 insertions(+)

Index: linux-2.6.git/include/net/netns/x_tables.h
=====================================================================
--- linux-2.6.git.orig/include/net/netns/x_tables.h
+++ linux-2.6.git/include/net/netns/x_tables.h
@@ -8,8 +8,11 @@ struct ebt_table;
 
 struct netns_xt {
 	struct list_head tables[NFPROTO_NUMPROTO];
+#if defined(CONFIG_BRIDGE_NF_EBTABLES) || \
+    defined(CONFIG_BRIDGE_NF_EBTABLES_MODULE)
 	struct ebt_table *broute_table;
 	struct ebt_table *frame_filter;
 	struct ebt_table *frame_nat;
+#endif
 };
 #endif

