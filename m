From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH net 4/4] qlcnic: Fix ordering of stats in stats buffer.
Date: Mon, 22 Sep 2014 05:51:53 -0400
Message-ID: <1411379513-26902-5-git-send-email-manish.chopra@qlogic.com>
References: <1411379513-26902-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-GELinuxNICDev@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:27875 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753198AbaIVKZt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 06:25:49 -0400
In-Reply-To: <1411379513-26902-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o When TX queues are not allocated, driver does not fill TX queues stats in the buffer.
  However, it is also not advancing data pointer by TX queue stats length, which would
  misplace all successive stats data in the buffer and will result in mismatch between
  stats strings and it's values.

o Fix this by advancing data pointer by TX queue stats length when
  queues are not allocated.

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
---
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
index 863c445..494e810 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
@@ -1343,6 +1343,8 @@ static void qlcnic_get_ethtool_stats(struct net_device *dev,
 			tx_ring = &adapter->tx_ring[ring];
 			data = qlcnic_fill_tx_queue_stats(data, tx_ring);
 			qlcnic_update_stats(adapter);
+		} else {
+			data += QLCNIC_TX_STATS_LEN;
 		}
 	}
 
-- 
1.7.1
