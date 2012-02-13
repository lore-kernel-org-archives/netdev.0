From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] bnx2x: fix bnx2x_storm_stats_update() on big endian
Date: Mon, 13 Feb 2012 17:23:12 +0100
Message-ID: <1329150192.2494.22.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Eilon Greenstein <eilong@broadcom.com>,
	Vladislav Zolotarov <vladz@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:34158 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755308Ab2BMQXQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2012 11:23:16 -0500
Received: by wgbdt10 with SMTP id dt10so5052598wgb.1
        for <netdev@vger.kernel.org>; Mon, 13 Feb 2012 08:23:15 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 619c5cb6885 (New 7.0 FW: bnx2x, cnic, bnx2i, bnx2fc) added new
sparse warnings.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Eilon Greenstein <eilong@broadcom.com>
Cc: Vladislav Zolotarov <vladz@broadcom.com>
Cc: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
index 7b9b304..320ecb8 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
@@ -1081,17 +1081,17 @@ static int bnx2x_storm_stats_update(struct bnx2x *bp)
 	       estats->rx_stat_ifhcinbadoctets_lo);
 
 	ADD_64(fstats->total_bytes_received_hi,
-	       tfunc->rcv_error_bytes.hi,
+	       le32_to_cpu(tfunc->rcv_error_bytes.hi),
 	       fstats->total_bytes_received_lo,
-	       tfunc->rcv_error_bytes.lo);
+	       le32_to_cpu(tfunc->rcv_error_bytes.lo));
 
 	memcpy(estats, &(fstats->total_bytes_received_hi),
 	       sizeof(struct host_func_stats) - 2*sizeof(u32));
 
 	ADD_64(estats->error_bytes_received_hi,
-	       tfunc->rcv_error_bytes.hi,
+	       le32_to_cpu(tfunc->rcv_error_bytes.hi),
 	       estats->error_bytes_received_lo,
-	       tfunc->rcv_error_bytes.lo);
+	       le32_to_cpu(tfunc->rcv_error_bytes.lo));
 
 	ADD_64(estats->etherstatsoverrsizepkts_hi,
 	       estats->rx_stat_dot3statsframestoolong_hi,
