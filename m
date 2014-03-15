From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 11/16] s2io: Don't receive packets when the napi budget == 0
Date: Fri, 14 Mar 2014 18:06:26 -0700
Message-ID: <87bnx8xobx.fsf_-_@xmission.com>
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
Received: from out03.mta.xmission.com ([166.70.13.233]:35376 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754170AbaCOBGc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 21:06:32 -0400
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
 drivers/net/ethernet/neterion/s2io.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/neterion/s2io.c b/drivers/net/ethernet/neterion/s2io.c
index 56e3a9d42bb2..d44fdb91808e 100644
--- a/drivers/net/ethernet/neterion/s2io.c
+++ b/drivers/net/ethernet/neterion/s2io.c
@@ -2914,6 +2914,9 @@ static int rx_intr_handler(struct ring_info *ring_data, int budget)
 	struct RxD1 *rxdp1;
 	struct RxD3 *rxdp3;
 
+	if (budget <= 0)
+		return napi_pkts;
+
 	get_info = ring_data->rx_curr_get_info;
 	get_block = get_info.block_index;
 	memcpy(&put_info, &ring_data->rx_curr_put_info, sizeof(put_info));
-- 
1.7.5.4
