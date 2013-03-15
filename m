From: roy.qing.li@gmail.com
Subject: [PATCH net-next] ipv4: replace ip_fast_csum with csum_replace2
Date: Fri, 15 Mar 2013 16:50:18 +0800
Message-ID: <1363337418-9609-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gh0-f178.google.com ([209.85.160.178]:45164 "EHLO
	mail-gh0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753739Ab3COJOJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Mar 2013 05:14:09 -0400
Received: by mail-gh0-f178.google.com with SMTP id g24so568088ghb.37
        for <netdev@vger.kernel.org>; Fri, 15 Mar 2013 02:14:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

replace ip_fast_csum with csum_replace2 to save cpu cycles

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/ipv4/inet_lro.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/inet_lro.c b/net/ipv4/inet_lro.c
index cc280a3..1975f52 100644
--- a/net/ipv4/inet_lro.c
+++ b/net/ipv4/inet_lro.c
@@ -29,6 +29,7 @@
 #include <linux/module.h>
 #include <linux/if_vlan.h>
 #include <linux/inet_lro.h>
+#include <net/checksum.h>
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Jan-Bernd Themann <themann@de.ibm.com>");
@@ -114,11 +115,9 @@ static void lro_update_tcp_ip_header(struct net_lro_desc *lro_desc)
 		*(p+2) = lro_desc->tcp_rcv_tsecr;
 	}
 
+	csum_replace2(&iph->check, iph->tot_len, htons(lro_desc->ip_tot_len));
 	iph->tot_len = htons(lro_desc->ip_tot_len);
 
-	iph->check = 0;
-	iph->check = ip_fast_csum((u8 *)lro_desc->iph, iph->ihl);
-
 	tcph->check = 0;
 	tcp_hdr_csum = csum_partial(tcph, TCP_HDR_LEN(tcph), 0);
 	lro_desc->data_csum = csum_add(lro_desc->data_csum, tcp_hdr_csum);
-- 
1.7.10.4
