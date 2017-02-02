From: "Jonathan T. Leighton" <jtleight@udel.edu>
Subject: [PATCH RFC 1/2] ipv6: Inhibit IPv4-mapped src address on the wire.
Date: Thu,  2 Feb 2017 13:27:54 -0500
Message-ID: <9b389c5354e84984d1def249a24e58f071e78aeb.1485894457.git.jtleight@udel.edu>
References: <cover.1485894457.git.jtleight@udel.edu>
Cc: "Jonathan T. Leighton" <jtleight@udel.edu>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:34908 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751377AbdBBS2J (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 13:28:09 -0500
Received: by mail-qt0-f195.google.com with SMTP id s58so5722521qtc.2
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 10:28:08 -0800 (PST)
In-Reply-To: <cover.1485894457.git.jtleight@udel.edu>
In-Reply-To: <cover.1485894457.git.jtleight@udel.edu>
References: <cover.1485894457.git.jtleight@udel.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a check for the problematic case of an IPv4-mapped IPv6
source address and a destination address that is neither an IPv4-mapped
IPv6 address nor in6addr_any, and returns an appropriate error. The
check in done before returning from looking up the route.

Signed-off-by: Jonathan T. Leighton <jtleight@udel.edu>
---
 net/ipv6/ip6_output.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 38122d0..7969c1e 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1021,6 +1021,9 @@ static int ip6_dst_lookup_tail(struct net *net, const struct sock *sk,
 		}
 	}
 #endif
+	if (ipv6_addr_v4mapped(&fl6->saddr) &&
+	    !(ipv6_addr_v4mapped(&fl6->daddr) || ipv6_addr_any(&fl6->daddr)))
+		return -EAFNOSUPPORT;
 
 	return 0;
 
-- 
2.7.4
