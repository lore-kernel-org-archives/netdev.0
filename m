From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 12/39] mv643xx_eth: get rid of RX_BUF_OFFSET
Date: Tue,  3 Jun 2008 13:02:27 +0200
Message-ID: <1212490974-23719-13-git-send-email-buytenh@wantstofly.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Cc: netdev@vger.kernel.org
To: Dale Farnsworth <dale@farnsworth.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:48766 "EHLO
	delta.wantstofly.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756350AbYFCMAp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 08:00:45 -0400
In-Reply-To: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Get rid of RX_BUF_OFFSET (which is synonymous with ETH_HW_IP_ALIGN).

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index b3f4fd8..3c5c992 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -160,9 +160,6 @@ static char mv643xx_driver_version[] = "1.0";
 #define PORT_DEFAULT_TRANSMIT_QUEUE_SIZE	800
 #define PORT_DEFAULT_RECEIVE_QUEUE_SIZE		400
 
-/* Buffer offset from buffer pointer */
-#define RX_BUF_OFFSET				0x2
-
 /* Gigabit Ethernet Unit Global Registers */
 
 /* MIB Counters register definitions */
@@ -682,9 +679,9 @@ static ETH_FUNC_RET_STATUS eth_port_receive(struct mv643xx_private *mp,
 		return ETH_END_OF_JOB;
 	}
 
-	p_pkt_info->byte_cnt = (p_rx_desc->byte_cnt) - RX_BUF_OFFSET;
+	p_pkt_info->byte_cnt = p_rx_desc->byte_cnt - ETH_HW_IP_ALIGN;
 	p_pkt_info->cmd_sts = command_status;
-	p_pkt_info->buf_ptr = (p_rx_desc->buf_ptr) + RX_BUF_OFFSET;
+	p_pkt_info->buf_ptr = p_rx_desc->buf_ptr + ETH_HW_IP_ALIGN;
 	p_pkt_info->return_info = mp->rx_skb[rx_curr_desc];
 	p_pkt_info->l4i_chk = p_rx_desc->buf_size;
 
-- 
1.5.3.4

