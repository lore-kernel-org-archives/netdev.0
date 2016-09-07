From: Lorenzo Colitti <lorenzo@google.com>
Subject: [PATCH net-next] net: diag: make udp_diag_destroy work for mapped addresses.
Date: Wed,  7 Sep 2016 13:38:35 +0900
Message-ID: <1473223115-144755-1-git-send-email-lorenzo@google.com>
Cc: ek@google.com, eric.dumazet@gmail.com, davem@davemloft.net,
        dsa@cumulusnetworks.com, Lorenzo Colitti <lorenzo@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:34952 "EHLO
        mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751147AbcIGEis (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 00:38:48 -0400
Received: by mail-pa0-f54.google.com with SMTP id b2so2080967pat.2
        for <netdev@vger.kernel.org>; Tue, 06 Sep 2016 21:38:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

udp_diag_destroy does look up the IPv4 UDP hashtable for mapped
addresses, but it gets the IPv4 address to look up from the
beginning of the IPv6 address instead of the end.

Tested: https://android-review.googlesource.com/269874
Fixes: 5d77dca82839 ("net: diag: support SOCK_DESTROY for UDP sockets")
Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
---
 net/ipv4/udp_diag.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/udp_diag.c b/net/ipv4/udp_diag.c
index 8a9f6e5..58b79c0 100644
--- a/net/ipv4/udp_diag.c
+++ b/net/ipv4/udp_diag.c
@@ -186,8 +186,8 @@ static int __udp_diag_destroy(struct sk_buff *in_skb,
 		if (ipv6_addr_v4mapped((struct in6_addr *)req->id.idiag_dst) &&
 		    ipv6_addr_v4mapped((struct in6_addr *)req->id.idiag_src))
 			sk = __udp4_lib_lookup(net,
-					req->id.idiag_dst[0], req->id.idiag_dport,
-					req->id.idiag_src[0], req->id.idiag_sport,
+					req->id.idiag_dst[3], req->id.idiag_dport,
+					req->id.idiag_src[3], req->id.idiag_sport,
 					req->id.idiag_if, tbl, NULL);
 
 		else
-- 
2.8.0.rc3.226.g39d4020
