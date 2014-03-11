From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 1/2] bnx2: Don't receive packets when the napi budget == 0
Date: Tue, 11 Mar 2014 14:31:09 -0700
Message-ID: <871ty88lsy.fsf_-_@xmission.com>
References: <87a9cxf7mp.fsf_-_@xmission.com>
	<20140311.124907.1180556684992271103.davem@davemloft.net>
	<87wqg0cy9d.fsf@xmission.com>
	<20140311.160931.1395978386605601765.davem@davemloft.net>
	<877g808luk.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:60539 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752059AbaCKVbQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 17:31:16 -0400
In-Reply-To: <877g808luk.fsf_-_@xmission.com> (Eric W. Biederman's message of
	"Tue, 11 Mar 2014 14:30:11 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Processing any incoming packets with a with a napi budget of 0
is incorrect driver behavior.

This matters as netpoll will shortly call drivers with a budget of 0
to avoid receive packet processing happening in hard irq context.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/net/ethernet/broadcom/bnx2.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index c251ca3056de..2e42de239798 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -3132,6 +3132,9 @@ bnx2_rx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 	struct l2_fhdr *rx_hdr;
 	int rx_pkt = 0, pg_ring_used = 0;
 
+	if (budget <= 0)
+		return rx_pkt;
+
 	hw_cons = bnx2_get_hw_rx_cons(bnapi);
 	sw_cons = rxr->rx_cons;
 	sw_prod = rxr->rx_prod;
-- 
1.7.5.4
