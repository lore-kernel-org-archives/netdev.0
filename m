From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 09/50] netfilter: nf_conntrack_tuple_common.h: fix #include
Date: Wed,  7 Dec 2016 22:52:15 +0100
Message-ID: <1481147576-5690-10-git-send-email-pablo@netfilter.org>
References: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:60092 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933213AbcLGVxQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Dec 2016 16:53:16 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 4C527C514C
        for <netdev@vger.kernel.org>; Wed,  7 Dec 2016 22:53:15 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 3ADFEDA853
        for <netdev@vger.kernel.org>; Wed,  7 Dec 2016 22:53:15 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 1E29CDA86E
        for <netdev@vger.kernel.org>; Wed,  7 Dec 2016 22:53:13 +0100 (CET)
In-Reply-To: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Davide Caratti <dcaratti@redhat.com>

To allow usage of enum ip_conntrack_dir in include/net/netns/conntrack.h,
this patch encloses #include <linux/netfilter.h> in a #ifndef __KERNEL__
directive, so that compiler errors caused by unwanted inclusion of
include/linux/netfilter.h are avoided.
In addition, #include <linux/netfilter/nf_conntrack_common.h> line has
been added to resolve correctly CTINFO2DIR macro.

Signed-off-by: Davide Caratti <dcaratti@redhat.com>
Acked-by: Mikko Rapeli <mikko.rapeli@iki.fi>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/uapi/linux/netfilter/nf_conntrack_tuple_common.h | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/include/uapi/linux/netfilter/nf_conntrack_tuple_common.h b/include/uapi/linux/netfilter/nf_conntrack_tuple_common.h
index a9c3834abdd4..526b42496b78 100644
--- a/include/uapi/linux/netfilter/nf_conntrack_tuple_common.h
+++ b/include/uapi/linux/netfilter/nf_conntrack_tuple_common.h
@@ -2,7 +2,10 @@
 #define _NF_CONNTRACK_TUPLE_COMMON_H
 
 #include <linux/types.h>
+#ifndef __KERNEL__
 #include <linux/netfilter.h>
+#endif
+#include <linux/netfilter/nf_conntrack_common.h> /* IP_CT_IS_REPLY */
 
 enum ip_conntrack_dir {
 	IP_CT_DIR_ORIGINAL,
-- 
2.1.4
