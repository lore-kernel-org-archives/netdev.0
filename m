From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 07/23] netfilter: nf_ct_sctp: move ip_ct_sctp away from UAPI
Date: Fri, 18 Dec 2015 21:26:33 +0100
Message-ID: <1450470409-31427-8-git-send-email-pablo@netfilter.org>
References: <1450470409-31427-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:57993 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965173AbbLRUeF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Dec 2015 15:34:05 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 82EE917F1D4
	for <netdev@vger.kernel.org>; Fri, 18 Dec 2015 21:34:04 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 1E3B9DA80D
	for <netdev@vger.kernel.org>; Fri, 18 Dec 2015 21:34:04 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 869DDDA249
	for <netdev@vger.kernel.org>; Fri, 18 Dec 2015 21:33:44 +0100 (CET)
In-Reply-To: <1450470409-31427-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

ip_ct_sctp is an internal structure, embedded by the union
nf_conntrack_proto to store sctp-specific information at conntrack
entries. It has no business with UAPI.

This patch moves it from UAPI to a saner place, together with similar
structs for other protocols.

Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Acked-by: Neil Horman <nhorman@tuxdriver.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter/nf_conntrack_sctp.h      | 13 +++++++++++++
 include/uapi/linux/netfilter/nf_conntrack_sctp.h | 12 +++---------
 2 files changed, 16 insertions(+), 9 deletions(-)
 create mode 100644 include/linux/netfilter/nf_conntrack_sctp.h

diff --git a/include/linux/netfilter/nf_conntrack_sctp.h b/include/linux/netfilter/nf_conntrack_sctp.h
new file mode 100644
index 0000000..22a16a2
--- /dev/null
+++ b/include/linux/netfilter/nf_conntrack_sctp.h
@@ -0,0 +1,13 @@
+#ifndef _NF_CONNTRACK_SCTP_H
+#define _NF_CONNTRACK_SCTP_H
+/* SCTP tracking. */
+
+#include <uapi/linux/netfilter/nf_conntrack_sctp.h>
+
+struct ip_ct_sctp {
+	enum sctp_conntrack state;
+
+	__be32 vtag[IP_CT_DIR_MAX];
+};
+
+#endif /* _NF_CONNTRACK_SCTP_H */
diff --git a/include/uapi/linux/netfilter/nf_conntrack_sctp.h b/include/uapi/linux/netfilter/nf_conntrack_sctp.h
index ed4e776..2cbc366 100644
--- a/include/uapi/linux/netfilter/nf_conntrack_sctp.h
+++ b/include/uapi/linux/netfilter/nf_conntrack_sctp.h
@@ -1,5 +1,5 @@
-#ifndef _NF_CONNTRACK_SCTP_H
-#define _NF_CONNTRACK_SCTP_H
+#ifndef _UAPI_NF_CONNTRACK_SCTP_H
+#define _UAPI_NF_CONNTRACK_SCTP_H
 /* SCTP tracking. */
 
 #include <linux/netfilter/nf_conntrack_tuple_common.h>
@@ -18,10 +18,4 @@ enum sctp_conntrack {
 	SCTP_CONNTRACK_MAX
 };
 
-struct ip_ct_sctp {
-	enum sctp_conntrack state;
-
-	__be32 vtag[IP_CT_DIR_MAX];
-};
-
-#endif /* _NF_CONNTRACK_SCTP_H */
+#endif /* _UAPI_NF_CONNTRACK_SCTP_H */
-- 
2.1.4
