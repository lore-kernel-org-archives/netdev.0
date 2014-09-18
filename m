From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] bnx2x: set gso_segs in LRO mode
Date: Thu, 18 Sep 2014 13:48:44 -0700
Message-ID: <1411073324.7106.294.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Ariel Elior <ariel.elior@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:65029 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757049AbaIRUsq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2014 16:48:46 -0400
Received: by mail-pa0-f46.google.com with SMTP id kq14so2295128pab.5
        for <netdev@vger.kernel.org>; Thu, 18 Sep 2014 13:48:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

In commits cbf1de72324a8 ("bnx2x: fix GRO parameters"), and
ab5777d748302 ("bnx2x: Get gso_segs from FW")
special care was taken for GRO mode.

We can also get proper gso_segs for LRO mode.

This helps to get proper values for these SNMP counters, which should
count number of segments. This also helps qdisc_pkt_len_init() to better
track packet sizes when ingress qdisc is in place.

IpExtInNoECTPkts                63458
IpExtInECT0Pkts                 8772480
IpExtInCEPkts                   1390713

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 6dc32aee96bf..9c0c0f4bdfc3 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -537,8 +537,10 @@ static void bnx2x_set_gro_params(struct sk_buff *skb, u16 parsing_flags,
 
 	/* tcp_gro_complete() will copy NAPI_GRO_CB(skb)->count
 	 * to skb_shinfo(skb)->gso_segs
+	 * We also set skb_shinfo(skb)->gso_segs in case we are in LRO mode
 	 */
 	NAPI_GRO_CB(skb)->count = num_of_coalesced_segs;
+	skb_shinfo(skb)->gso_segs = num_of_coalesced_segs;
 }
 
 static int bnx2x_alloc_rx_sge(struct bnx2x *bp, struct bnx2x_fastpath *fp,
