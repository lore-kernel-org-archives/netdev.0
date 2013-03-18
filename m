From: roy.qing.li@gmail.com
Subject: [PATCH net-next] net: neterion: replace ip_fast_csum with csum_replace2
Date: Mon, 18 Mar 2013 16:34:48 +0800
Message-ID: <1363595688-16004-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f49.google.com ([209.85.128.49]:62951 "EHLO
	mail-qe0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751644Ab3CRIez (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Mar 2013 04:34:55 -0400
Received: by mail-qe0-f49.google.com with SMTP id 1so3129357qec.22
        for <netdev@vger.kernel.org>; Mon, 18 Mar 2013 01:34:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

replace ip_fast_csum with csum_replace2 to save cpu cycles

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 drivers/net/ethernet/neterion/s2io.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/neterion/s2io.c b/drivers/net/ethernet/neterion/s2io.c
index bfd8873..3371ff4 100644
--- a/drivers/net/ethernet/neterion/s2io.c
+++ b/drivers/net/ethernet/neterion/s2io.c
@@ -80,6 +80,7 @@
 #include <linux/slab.h>
 #include <linux/prefetch.h>
 #include <net/tcp.h>
+#include <net/checksum.h>
 
 #include <asm/div64.h>
 #include <asm/irq.h>
@@ -8337,16 +8338,13 @@ static void update_L3L4_header(struct s2io_nic *sp, struct lro *lro)
 {
 	struct iphdr *ip = lro->iph;
 	struct tcphdr *tcp = lro->tcph;
-	__sum16 nchk;
 	struct swStat *swstats = &sp->mac_control.stats_info->sw_stat;
 
 	DBG_PRINT(INFO_DBG, "%s: Been here...\n", __func__);
 
 	/* Update L3 header */
+	csum_replace2(&ip->check, ip->tot_len, htons(lro->total_len));
 	ip->tot_len = htons(lro->total_len);
-	ip->check = 0;
-	nchk = ip_fast_csum((u8 *)lro->iph, ip->ihl);
-	ip->check = nchk;
 
 	/* Update L4 header */
 	tcp->ack_seq = lro->tcp_ack;
-- 
1.7.10.4
