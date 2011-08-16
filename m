From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 3/5] ethtool: Correct description of
 'max_coalesced_frames' fields
Date: Tue, 16 Aug 2011 01:07:47 +0100
Message-ID: <1313453267.2731.59.camel@bwh-desktop>
References: <1313453180.2731.57.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eli Cohen <eli@dev.mellanox.co.il>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:41139 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751351Ab1HPAHu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2011 20:07:50 -0400
In-Reply-To: <1313453180.2731.57.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current descriptions state that these fields specify 'How many
packets to delay ... after a packet ...' which implies that the
hardware should wait for (max_coalesced_frames + 1) completions before
generating an interrupt.  It is also stated that setting both this
field and the corresponding 'coalesce_usecs' field to 0 is invalid.
Together, this implies that the hardware must always be configured
to delay a completion IRQ for at least 1 usec or 1 more completion.

I believe that the addition of 1 is not intended, and David Miller
confirms that the original implementation (in tg3) does not do this.
Clarify the descriptions of these fields to avoid this interpretation.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 include/linux/ethtool.h |   26 +++++++++++++-------------
 1 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 71d45a1..18059ca 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -122,8 +122,8 @@ struct ethtool_eeprom {
  * @cmd: ETHTOOL_{G,S}COALESCE
  * @rx_coalesce_usecs: How many usecs to delay an RX interrupt after
  *	a packet arrives.  If 0, only @rx_max_coalesced_frames is used.
- * @rx_max_coalesced_frames: How many packets to delay an RX interrupt
- *	after a packet arrives.  If 0, only @rx_coalesce_usecs is used.
+ * @rx_max_coalesced_frames: Maximum number of packets to receive
+ *	before an RX interrupt.  If 0, only @rx_coalesce_usecs is used.
  * @rx_coalesce_usecs_irq: Same as @rx_coalesce_usecs, except that
  *	this value applies while an IRQ is being serviced by the host.
  * @rx_max_coalesced_frames_irq: Same as @rx_max_coalesced_frames,
@@ -132,9 +132,9 @@ struct ethtool_eeprom {
  * @tx_coalesce_usecs: How many usecs to delay a TX interrupt after
  *	a packet is sent.  If 0, only @tx_max_coalesced_frames
  *	is used.
- * @tx_max_coalesced_frames: How many packets to delay a TX interrupt
- *	after a packet is sent.  If 0, only @tx_coalesce_usecs is
- *	used.
+ * @tx_max_coalesced_frames: Maximum number of packets to be sent
+ *	before a TX interrupt.  If 0, only @tx_coalesce_usecs is
+ *     used.
  * @tx_coalesce_usecs_irq: Same as @tx_coalesce_usecs, except that
  *	this value applies while an IRQ is being serviced by the host.
  * @tx_max_coalesced_frames_irq: Same as @tx_max_coalesced_frames,
@@ -149,21 +149,21 @@ struct ethtool_eeprom {
  * @pkt_rate_low: Threshold for low packet rate (packets per second).
  * @rx_coalesce_usecs_low: How many usecs to delay an RX interrupt after
  *	a packet arrives, when the packet rate is below @pkt_rate_low.
- * @rx_max_coalesced_frames_low: How many packets to delay an RX interrupt
- *	after a packet arrives, when the packet rate is below @pkt_rate_low.
+ * @rx_max_coalesced_frames_low: Maximum number of packets to be received
+ *	before an RX interrupt, when the packet rate is below @pkt_rate_low.
  * @tx_coalesce_usecs_low: How many usecs to delay a TX interrupt after
  *	a packet is sent, when the packet rate is below @pkt_rate_low.
- * @tx_max_coalesced_frames_low: How many packets to delay a TX interrupt
- *	after a packet is sent, when the packet rate is below @pkt_rate_low.
+ * @tx_max_coalesced_frames_low: Maximum nuumber of packets to be sent before
+ *	a TX interrupt, when the packet rate is below @pkt_rate_low.
  * @pkt_rate_high: Threshold for high packet rate (packets per second).
  * @rx_coalesce_usecs_high: How many usecs to delay an RX interrupt after
  *	a packet arrives, when the packet rate is above @pkt_rate_high.
- * @rx_max_coalesced_frames_high: How many packets to delay an RX interrupt
- *	after a packet arrives, when the packet rate is above @pkt_rate_high.
+ * @rx_max_coalesced_frames_high: Maximum number of packets to be received
+ *	before an RX interrupt, when the packet rate is above @pkt_rate_high.
  * @tx_coalesce_usecs_high: How many usecs to delay a TX interrupt after
  *	a packet is sent, when the packet rate is above @pkt_rate_high.
- * @tx_max_coalesced_frames_high: How many packets to delay a TX interrupt
- *	after a packet is sent, when the packet rate is above @pkt_rate_high.
+ * @tx_max_coalesced_frames_high: Maximum number of packets to be sent before
+ *	a TX interrupt, when the packet rate is above @pkt_rate_high.
  * @rate_sample_interval: How often to do adaptive coalescing packet rate
  *	sampling, measured in seconds.  Must not be zero.
  *
-- 
1.7.4.4



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

