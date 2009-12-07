From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 3/3] ixgb: increase skb size to prevent dma over skb
	boundary
Date: Mon, 7 Dec 2009 09:49:22 -0500
Message-ID: <20091207144922.GD8073@hmsreliant.think-freely.org>
References: <20091207144623.GA8073@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	peter.p.waskiewicz.jr@intel.com, john.ronciak@intel.com
To: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:35037 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757332AbZLGOtR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2009 09:49:17 -0500
Content-Disposition: inline
In-Reply-To: <20091207144623.GA8073@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update xgb driver to not allow dma beyond the end of the allocated skb
    
Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

ixgb_main.c |   13 +++++++++----
1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index bcd0f01..2d8e699 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -798,14 +798,19 @@ ixgb_setup_rctl(struct ixgb_adapter *adapter)
 
 	rctl |= IXGB_RCTL_SECRC;
 
-	if (adapter->rx_buffer_len <= IXGB_RXBUFFER_2048)
+	if (adapter->rx_buffer_len <= IXGB_RXBUFFER_2048) {
 		rctl |= IXGB_RCTL_BSIZE_2048;
-	else if (adapter->rx_buffer_len <= IXGB_RXBUFFER_4096)
+		adapter->rx_buffer_len = IXGB_RXBUFFER_2048;
+	} else if (adapter->rx_buffer_len <= IXGB_RXBUFFER_4096) {
 		rctl |= IXGB_RCTL_BSIZE_4096;
-	else if (adapter->rx_buffer_len <= IXGB_RXBUFFER_8192)
+		adapter->rx_buffer_len = IXGB_RXBUFFER_4096;
+	} else if (adapter->rx_buffer_len <= IXGB_RXBUFFER_8192) {
 		rctl |= IXGB_RCTL_BSIZE_8192;
-	else if (adapter->rx_buffer_len <= IXGB_RXBUFFER_16384)
+		adapter->rx_buffer_len = IXGB_RXBUFFER_8192;
+	} else if (adapter->rx_buffer_len <= IXGB_RXBUFFER_16384) {
 		rctl |= IXGB_RCTL_BSIZE_16384;
+		adapter->rx_buffer_len = IXGB_RXBUFFER_16384;
+	}
 
 	IXGB_WRITE_REG(&adapter->hw, RCTL, rctl);
 }
