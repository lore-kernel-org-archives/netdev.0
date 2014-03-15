From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 02/16] i40e: Don't receive packets when the napi budget == 0
Date: Fri, 14 Mar 2014 17:59:10 -0700
Message-ID: <87pploz38h.fsf_-_@xmission.com>
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
Received: from out02.mta.xmission.com ([166.70.13.232]:57593 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753921AbaCOA7R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 20:59:17 -0400
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
 drivers/net/ethernet/intel/i40e/i40e_txrx.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 2081bdb214e5..2c21dd5ddcb6 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1264,6 +1264,9 @@ static int i40e_clean_rx_irq(struct i40e_ring *rx_ring, int budget)
 	u8 rx_ptype;
 	u64 qword;
 
+	if (budget <= 0)
+		return 0;
+
 	rx_desc = I40E_RX_DESC(rx_ring, i);
 	qword = le64_to_cpu(rx_desc->wb.qword1.status_error_len);
 	rx_status = (qword & I40E_RXD_QW1_STATUS_MASK) >>
-- 
1.7.5.4
