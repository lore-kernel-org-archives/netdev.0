From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH nf-next 3/5] netlink: add NLM_F_NONREC flag for deletion requests
Date: Sun,  3 Sep 2017 23:55:59 +0200
Message-ID: <1504475761-11454-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:47196 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752960AbdICV4Q (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 3 Sep 2017 17:56:16 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id AD01911D8F6
        for <netdev@vger.kernel.org>; Sun,  3 Sep 2017 23:55:49 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 9C88DB5030
        for <netdev@vger.kernel.org>; Sun,  3 Sep 2017 23:55:49 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the last NFWS in Faro, Portugal, we discussed that netlink is lacking
the semantics to request non recursive deletions, ie. do not delete an
object iff it has child objects that hang from this parent object that
the user requests to be deleted.

We need this new flag to solve a problem for the iptables-compat
backward compatibility utility, that runs iptables commands using the
existing nf_tables netlink interface. Specifically, custom chains in
iptables cannot be deleted if there are rules in it, however, nf_tables
allows to remove any chain that is populated with content. To sort out
this asymmetry, iptables-compat userspace sets this new NLM_F_NONREC
flag to obtain the same semantics that iptables provides.

This new flag should only be used for deletion requests. Note this new
flag value overlaps with the existing:

* NLM_F_ROOT for get requests.
* NLM_F_REPLACE for new requests.

However, those flags should not ever be used in deletion requests.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
@David: Please, acknowledge this if you think this is fine so I can
        take this into the nf-next tree, given patches 4/5 and 5/5
        depend on this. Thanks a lot!

 include/uapi/linux/netlink.h | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/include/uapi/linux/netlink.h b/include/uapi/linux/netlink.h
index f4fc9c9e123d..e8af60a7c56d 100644
--- a/include/uapi/linux/netlink.h
+++ b/include/uapi/linux/netlink.h
@@ -69,6 +69,9 @@ struct nlmsghdr {
 #define NLM_F_CREATE	0x400	/* Create, if it does not exist	*/
 #define NLM_F_APPEND	0x800	/* Add to end of list		*/
 
+/* Modifiers to DELETE request */
+#define NLM_F_NONREC	0x100	/* Do not delete recursively	*/
+
 /* Flags for ACK message */
 #define NLM_F_CAPPED	0x100	/* request was capped */
 #define NLM_F_ACK_TLVS	0x200	/* extended ACK TVLs were included */
-- 
2.1.4
