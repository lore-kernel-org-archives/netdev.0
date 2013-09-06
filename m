From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net/stable] ipv6/exthdrs: accept tlv which includes only padding
Date: Fri,  6 Sep 2013 16:02:25 +0200
Message-ID: <1378476145-6282-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, eldad@fogrefinery.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f53.google.com ([74.125.83.53]:33696 "EHLO
	mail-ee0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751391Ab3IFOCb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Sep 2013 10:02:31 -0400
Received: by mail-ee0-f53.google.com with SMTP id b15so1612541eek.26
        for <netdev@vger.kernel.org>; Fri, 06 Sep 2013 07:02:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In rfc4942 and rfc2460 I cannot find anything which would implicate to
drop packets which have only padding in tlv.

Current behaviour breaks TAHI Test v6LC.1.2.6.

Problem was intruduced in:
9b905fe6843 "ipv6/exthdrs: strict Pad1 and PadN check"

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/ipv6/exthdrs.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index 07a7d65..8d67900 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -162,12 +162,6 @@ static bool ip6_parse_tlv(const struct tlvtype_proc *procs, struct sk_buff *skb)
 		off += optlen;
 		len -= optlen;
 	}
-	/* This case will not be caught by above check since its padding
-	 * length is smaller than 7:
-	 * 1 byte NH + 1 byte Length + 6 bytes Padding
-	 */
-	if ((padlen == 6) && ((off - skb_network_header_len(skb)) == 8))
-		goto bad;
 
 	if (len == 0)
 		return true;
-- 
1.8.3.1
