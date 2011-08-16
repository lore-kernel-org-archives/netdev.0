From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 4/5] ethtool: Explicitly state the exit condition
 for interrupt coalescing
Date: Tue, 16 Aug 2011 01:08:37 +0100
Message-ID: <1313453317.2731.60.camel@bwh-desktop>
References: <1313453180.2731.57.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eli Cohen <eli@dev.mellanox.co.il>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:41160 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752390Ab1HPAIk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2011 20:08:40 -0400
In-Reply-To: <1313453180.2731.57.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also explicitly state how to disable interrupt coalescing.

Remove the now-redundant text from field descriptions.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 include/linux/ethtool.h |   19 +++++++++++--------
 1 files changed, 11 insertions(+), 8 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 18059ca..42378b3 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -121,20 +121,18 @@ struct ethtool_eeprom {
  * struct ethtool_coalesce - coalescing parameters for IRQs and stats updates
  * @cmd: ETHTOOL_{G,S}COALESCE
  * @rx_coalesce_usecs: How many usecs to delay an RX interrupt after
- *	a packet arrives.  If 0, only @rx_max_coalesced_frames is used.
+ *	a packet arrives.
  * @rx_max_coalesced_frames: Maximum number of packets to receive
- *	before an RX interrupt.  If 0, only @rx_coalesce_usecs is used.
+ *	before an RX interrupt.
  * @rx_coalesce_usecs_irq: Same as @rx_coalesce_usecs, except that
  *	this value applies while an IRQ is being serviced by the host.
  * @rx_max_coalesced_frames_irq: Same as @rx_max_coalesced_frames,
  *	except that this value applies while an IRQ is being serviced
  *	by the host.
  * @tx_coalesce_usecs: How many usecs to delay a TX interrupt after
- *	a packet is sent.  If 0, only @tx_max_coalesced_frames
- *	is used.
+ *	a packet is sent.
  * @tx_max_coalesced_frames: Maximum number of packets to be sent
- *	before a TX interrupt.  If 0, only @tx_coalesce_usecs is
- *     used.
+ *	before a TX interrupt.
  * @tx_coalesce_usecs_irq: Same as @tx_coalesce_usecs, except that
  *	this value applies while an IRQ is being serviced by the host.
  * @tx_max_coalesced_frames_irq: Same as @tx_max_coalesced_frames,
@@ -167,8 +165,13 @@ struct ethtool_eeprom {
  * @rate_sample_interval: How often to do adaptive coalescing packet rate
  *	sampling, measured in seconds.  Must not be zero.
  *
- * It is illegal to set both usecs and max frames to zero as this
- * would cause interrupts to never be generated.
+ * Each pair of (usecs, max_frames) fields specifies this exit
+ * condition for interrupt coalescing:
+ *	(usecs > 0 && time_since_first_completion >= usecs) ||
+ *	(max_frames > 0 && completed_frames >= max_frames)
+ * It is illegal to set both usecs and max_frames to zero as this
+ * would cause interrupts to never be generated.  To disable
+ * coalescing, set usecs = 0 and max_frames = 1.
  *
  * Adaptive RX/TX coalescing is an algorithm implemented by some
  * drivers to improve latency under low packet rates and improve
-- 
1.7.4.4



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

