From: Hans Schillstrom <hans@schillstrom.com>
Subject: [PATCH 1/1] ipv6: ipv6_find_hdr restore prev functionality
Date: Tue, 25 Feb 2014 11:54:11 +0100
Message-ID: <1393325651-11236-1-git-send-email-hans@schillstrom.com>
Cc: Hans Schillstrom <hans@schillstrom.com>
To: netdev@vger.kernel.org, davem@davemloft.net, ja@ssi.bg,
	aatteka@nicira.com, kaber@trash.net, ard@telegraafnet.nl
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-gw21.han.skanova.net ([81.236.55.21]:40490 "EHLO
	smtp-gw21.han.skanova.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752142AbaBYLBA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Feb 2014 06:01:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit 9195bb8e381d81d5a315f911904cdf0cfcc919b8
broke ipv6_find_hdr() for ipvs and possible also nft_exthdr_eval()
This patch simple exit if specified header is found.

Signed-off-by: Hans Schillstrom <hans@schillstrom.com>
---
 net/ipv6/exthdrs_core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/exthdrs_core.c b/net/ipv6/exthdrs_core.c
index 140748d..8af3eb5 100644
--- a/net/ipv6/exthdrs_core.c
+++ b/net/ipv6/exthdrs_core.c
@@ -212,7 +212,7 @@ int ipv6_find_hdr(const struct sk_buff *skb, unsigned int *offset,
 		found = (nexthdr == target);
 
 		if ((!ipv6_ext_hdr(nexthdr)) || nexthdr == NEXTHDR_NONE) {
-			if (target < 0)
+			if (target < 0 || found)
 				break;
 			return -ENOENT;
 		}
-- 
1.7.11.7
