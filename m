From: roy.qing.li@gmail.com
Subject: [PATCH net-next] driver/qlogic: replace ip_fast_csum with csum_replace2
Date: Fri, 15 Mar 2013 16:50:07 +0800
Message-ID: <1363337407-9573-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gh0-f178.google.com ([209.85.160.178]:60176 "EHLO
	mail-gh0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753223Ab3COIzP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Mar 2013 04:55:15 -0400
Received: by mail-gh0-f178.google.com with SMTP id g24so568055ghb.9
        for <netdev@vger.kernel.org>; Fri, 15 Mar 2013 01:55:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

replace ip_fast_csum with csum_replace2 to save cpu cycles

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c |    4 ++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c       |    7 +++----
 2 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
index 4782dcf..7692dfd 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
@@ -27,6 +27,7 @@
 #include <linux/delay.h>
 #include <linux/slab.h>
 #include <linux/if_vlan.h>
+#include <net/checksum.h>
 #include "netxen_nic.h"
 #include "netxen_nic_hw.h"
 
@@ -1641,9 +1642,8 @@ netxen_process_lro(struct netxen_adapter *adapter,
 	th = (struct tcphdr *)((skb->data + vhdr_len) + (iph->ihl << 2));
 
 	length = (iph->ihl << 2) + (th->doff << 2) + lro_length;
+	csum_replace2(&iph->check, iph->tot_len, htons(length));
 	iph->tot_len = htons(length);
-	iph->check = 0;
-	iph->check = ip_fast_csum((unsigned char *)iph, iph->ihl);
 	th->psh = push;
 	th->seq = htonl(seq_number);
 
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
index 0e63006..891f12d 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
@@ -9,6 +9,7 @@
 #include <linux/if_vlan.h>
 #include <net/ip.h>
 #include <linux/ipv6.h>
+#include <net/checksum.h>
 
 #include "qlcnic.h"
 
@@ -1132,9 +1133,8 @@ qlcnic_process_lro(struct qlcnic_adapter *adapter,
 		iph = (struct iphdr *)skb->data;
 		th = (struct tcphdr *)(skb->data + (iph->ihl << 2));
 		length = (iph->ihl << 2) + (th->doff << 2) + lro_length;
+		csum_replace2(&iph->check, iph->tot_len, htons(length));
 		iph->tot_len = htons(length);
-		iph->check = 0;
-		iph->check = ip_fast_csum((unsigned char *)iph, iph->ihl);
 	}
 
 	th->psh = push;
@@ -1595,9 +1595,8 @@ qlcnic_83xx_process_lro(struct qlcnic_adapter *adapter,
 		iph = (struct iphdr *)skb->data;
 		th = (struct tcphdr *)(skb->data + (iph->ihl << 2));
 		length = (iph->ihl << 2) + (th->doff << 2) + lro_length;
+		csum_replace2(&iph->check, iph->tot_len, htons(length));
 		iph->tot_len = htons(length);
-		iph->check = 0;
-		iph->check = ip_fast_csum((unsigned char *)iph, iph->ihl);
 	}
 
 	th->psh = push;
-- 
1.7.10.4
