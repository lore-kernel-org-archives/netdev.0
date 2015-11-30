From: Sunil Goutham <sunil.kovvuri@gmail.com>
Subject: [PATCH 03/13] net: thunderx: Increase transmit queue length
Date: Mon, 30 Nov 2015 23:48:59 +0530
Message-ID: <1448907549-5296-4-git-send-email-sunil.kovvuri@gmail.com>
References: <y>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Sunil.Goutham@caviumnetworks.com,
	Sunil Goutham <sgoutham@cavium.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <y>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sunil Goutham <sgoutham@cavium.com>

Under high transmit rates and with TSO enabled observing fluctuations
in TX performance. Seen especially with iperf3 application.

Since TSO is taken care at driver level, with 64KB of TSO packets
and when window size is also high the rate at which CPU fills in
transmit descriptors is much higher than what HW is able to process.
Each 64KB TSO packet occupies gets segmented to ~43 1500 byte MTU packets
and occupies ~130 descriptors. Hence increasing transmit queue size.

Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
---
 drivers/net/ethernet/cavium/thunder/nicvf_queues.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_queues.h b/drivers/net/ethernet/cavium/thunder/nicvf_queues.h
index fb4957d..b1e93a9 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_queues.h
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_queues.h
@@ -62,7 +62,7 @@
 #define SND_QUEUE_CNT		8
 #define CMP_QUEUE_CNT		8 /* Max of RCV and SND qcount */
 
-#define SND_QSIZE		SND_QUEUE_SIZE2
+#define SND_QSIZE		SND_QUEUE_SIZE3
 #define SND_QUEUE_LEN		(1ULL << (SND_QSIZE + 10))
 #define MAX_SND_QUEUE_LEN	(1ULL << (SND_QUEUE_SIZE6 + 10))
 #define SND_QUEUE_THRESH	2ULL
@@ -73,7 +73,7 @@
 /* Keep CQ and SQ sizes same, if timestamping
  * is enabled this equation will change.
  */
-#define CMP_QSIZE		CMP_QUEUE_SIZE2
+#define CMP_QSIZE		CMP_QUEUE_SIZE3
 #define CMP_QUEUE_LEN		(1ULL << (CMP_QSIZE + 10))
 #define CMP_QUEUE_CQE_THRESH	0
 #define CMP_QUEUE_TIMER_THRESH	220 /* 10usec */
-- 
1.7.1
