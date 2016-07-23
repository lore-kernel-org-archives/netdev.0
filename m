From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 12/25] netfilter: nf_conntrack_h323: fix off-by-one in DecodeQ931
Date: Sat, 23 Jul 2016 13:08:26 +0200
Message-ID: <1469272119-29942-13-git-send-email-pablo@netfilter.org>
References: <1469272119-29942-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:35930 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751543AbcGWLJ0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Jul 2016 07:09:26 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 5442BE7DAC
	for <netdev@vger.kernel.org>; Sat, 23 Jul 2016 13:09:25 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 44C17FC618
	for <netdev@vger.kernel.org>; Sat, 23 Jul 2016 13:09:25 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 92CE2FF2D4
	for <netdev@vger.kernel.org>; Sat, 23 Jul 2016 13:09:22 +0200 (CEST)
In-Reply-To: <1469272119-29942-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Toby DiPasquale <toby@cbcg.net>

This patch corrects an off-by-one error in the DecodeQ931 function in
the nf_conntrack_h323 module. This error could result in reading off
the end of a Q.931 frame.

Signed-off-by: Toby DiPasquale <toby@cbcg.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_h323_asn1.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nf_conntrack_h323_asn1.c b/net/netfilter/nf_conntrack_h323_asn1.c
index bcd5ed6..89b2e46 100644
--- a/net/netfilter/nf_conntrack_h323_asn1.c
+++ b/net/netfilter/nf_conntrack_h323_asn1.c
@@ -846,9 +846,10 @@ int DecodeQ931(unsigned char *buf, size_t sz, Q931 *q931)
 	sz -= len;
 
 	/* Message Type */
-	if (sz < 1)
+	if (sz < 2)
 		return H323_ERROR_BOUND;
 	q931->MessageType = *p++;
+	sz--;
 	PRINT("MessageType = %02X\n", q931->MessageType);
 	if (*p & 0x80) {
 		p++;
-- 
2.1.4
