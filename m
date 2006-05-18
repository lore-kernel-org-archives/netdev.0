From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] gre_unique_tuple: 16/32 bit fixes
Date: Thu, 18 May 2006 17:52:50 +0400
Message-ID: <20060518135250.GA30163@mipter.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from hu-out-0102.google.com ([72.14.214.207]:23812 "EHLO
	hu-out-0102.google.com") by vger.kernel.org with ESMTP
	id S932074AbWERNyR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 May 2006 09:54:17 -0400
Received: by hu-out-0102.google.com with SMTP id 23so185950huc
        for <netdev@vger.kernel.org>; Thu, 18 May 2006 06:54:16 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

GRE keys are 16 bit.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/ipv4/netfilter/ip_nat_proto_gre.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

--- a/net/ipv4/netfilter/ip_nat_proto_gre.c
+++ 1/net/ipv4/netfilter/ip_nat_proto_gre.c
@@ -81,14 +81,14 @@ gre_unique_tuple(struct ip_conntrack_tup
 		min = 1;
 		range_size = 0xffff;
 	} else {
-		min = ntohl(range->min.gre.key);
-		range_size = ntohl(range->max.gre.key) - min + 1;
+		min = ntohs(range->min.gre.key);
+		range_size = ntohs(range->max.gre.key) - min + 1;
 	}
 
 	DEBUGP("min = %u, range_size = %u\n", min, range_size); 
 
 	for (i = 0; i < range_size; i++, key++) {
-		*keyptr = htonl(min + key % range_size);
+		*keyptr = htons(min + key % range_size);
 		if (!ip_nat_used_tuple(tuple, conntrack))
 			return 1;
 	}

