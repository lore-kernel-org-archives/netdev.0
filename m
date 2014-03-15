From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 05/16] amd8111e: Don't receive packets when the napi budget == 0
Date: Fri, 14 Mar 2014 18:01:11 -0700
Message-ID: <87a9csz354.fsf_-_@xmission.com>
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
Received: from out02.mta.xmission.com ([166.70.13.232]:57952 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753921AbaCOBBS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 21:01:18 -0400
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
 drivers/net/ethernet/amd/amd8111e.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/amd/amd8111e.c b/drivers/net/ethernet/amd/amd8111e.c
index 2061b471fd16..26efaaa5e73f 100644
--- a/drivers/net/ethernet/amd/amd8111e.c
+++ b/drivers/net/ethernet/amd/amd8111e.c
@@ -720,6 +720,9 @@ static int amd8111e_rx_poll(struct napi_struct *napi, int budget)
 	int rx_pkt_limit = budget;
 	unsigned long flags;
 
+	if (rx_pkt_limit <= 0)
+		goto rx_not_empty;
+
 	do{
 		/* process receive packets until we use the quota*/
 		/* If we own the next entry, it's a new packet. Send it up. */
-- 
1.7.5.4
