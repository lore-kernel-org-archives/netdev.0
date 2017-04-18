From: David Lebrun <david.lebrun@uclouvain.be>
Subject: [PATCH net] ipv6: sr: fix out-of-bounds access in SRH validation
Date: Tue, 18 Apr 2017 17:59:49 +0200
Message-ID: <20170418155949.1028-1-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Lebrun <david.lebrun@uclouvain.be>,
        Andrey Konovalov <andreyknvl@google.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:40764 "EHLO
        smtp2.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932413AbdDRP76 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 11:59:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes an out-of-bounds access in seg6_validate_srh() when the
trailing data is less than sizeof(struct sr6_tlv).

Reported-by: Andrey Konovalov <andreyknvl@google.com>
Cc: Andrey Konovalov <andreyknvl@google.com>
Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>
---
 net/ipv6/seg6.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/ipv6/seg6.c b/net/ipv6/seg6.c
index a855eb3..5f44ffe 100644
--- a/net/ipv6/seg6.c
+++ b/net/ipv6/seg6.c
@@ -53,6 +53,9 @@ bool seg6_validate_srh(struct ipv6_sr_hdr *srh, int len)
 		struct sr6_tlv *tlv;
 		unsigned int tlv_len;
 
+		if (trailing < sizeof(*tlv))
+			return false;
+
 		tlv = (struct sr6_tlv *)((unsigned char *)srh + tlv_offset);
 		tlv_len = sizeof(*tlv) + tlv->len;
 
-- 
2.10.2
