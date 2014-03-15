From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 01/16] bnx2x: Don't receive packets when the napi budget == 0
Date: Fri, 14 Mar 2014 17:57:59 -0700
Message-ID: <87vbvgz3ag.fsf_-_@xmission.com>
References: <87a9cxf7mp.fsf_-_@xmission.com>
	<20140311.124907.1180556684992271103.davem@davemloft.net>
	<87wqg0cy9d.fsf@xmission.com>
	<20140311.160931.1395978386605601765.davem@davemloft.net>
	<877g808luk.fsf_-_@xmission.com> <871ty41dps.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:33974 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753921AbaCOA6G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 20:58:06 -0400
In-Reply-To: <871ty41dps.fsf_-_@xmission.com> (Eric W. Biederman's message of
	"Fri, 14 Mar 2014 17:56:47 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Processing any incoming packets with a with a napi budget of 0
is incorrect driver behavior.

This matters as netpoll will shortly call drivers with a budget of 0
to avoid receive packet processing happening in hard irq context.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 117b5c7f8ac9..acd494647f25 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -872,6 +872,8 @@ static int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget)
 	if (unlikely(bp->panic))
 		return 0;
 #endif
+	if (budget <= 0)
+		return rx_pkt;
 
 	bd_cons = fp->rx_bd_cons;
 	bd_prod = fp->rx_bd_prod;
-- 
1.7.5.4
