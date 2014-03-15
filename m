From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 09/16] sky2: Don't receive packets when the napi budget == 0
Date: Fri, 14 Mar 2014 18:05:26 -0700
Message-ID: <87mwgsxodl.fsf_-_@xmission.com>
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
Received: from out02.mta.xmission.com ([166.70.13.232]:58926 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753732AbaCOBFd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 21:05:33 -0400
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
 drivers/net/ethernet/marvell/sky2.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
index 2434611d1b4e..0ddfc43069ba 100644
--- a/drivers/net/ethernet/marvell/sky2.c
+++ b/drivers/net/ethernet/marvell/sky2.c
@@ -2735,6 +2735,9 @@ static int sky2_status_intr(struct sky2_hw *hw, int to_do, u16 idx)
 	unsigned int total_bytes[2] = { 0 };
 	unsigned int total_packets[2] = { 0 };
 
+	if (to_do <= 0)
+		return work_done;
+
 	rmb();
 	do {
 		struct sky2_port *sky2;
-- 
1.7.5.4
