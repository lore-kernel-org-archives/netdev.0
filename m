From: "Jonathan T. Leighton" <jtleight@udel.edu>
Subject: [PATCH 1/2] ipv6: Inhibit IPv4-mapped src address on the wire.
Date: Sun, 12 Feb 2017 17:26:06 -0500
Message-ID: <d45237d62bb04dda225d06eedc3a1fb049d568bb.1486937974.git.jtleight@udel.edu>
References: <cover.1486937974.git.jtleight@udel.edu>
Cc: "Jonathan T. Leighton" <jtleight@udel.edu>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:36263 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751583AbdBLW0M (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Feb 2017 17:26:12 -0500
Received: by mail-qt0-f194.google.com with SMTP id h53so10978953qth.3
        for <netdev@vger.kernel.org>; Sun, 12 Feb 2017 14:26:11 -0800 (PST)
In-Reply-To: <cover.1486937974.git.jtleight@udel.edu>
In-Reply-To: <cover.1486937974.git.jtleight@udel.edu>
References: <cover.1486937974.git.jtleight@udel.edu>
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
index a75871c..d0f51b4 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1022,6 +1022,9 @@ static int ip6_dst_lookup_tail(struct net *net, const struct sock *sk,
 		}
 	}
 #endif
+	if (ipv6_addr_v4mapped(&fl6->saddr) &&
+	    !(ipv6_addr_v4mapped(&fl6->daddr) || ipv6_addr_any(&fl6->daddr)))
+		return -EAFNOSUPPORT;
 
 	return 0;
 
-- 
2.7.4
