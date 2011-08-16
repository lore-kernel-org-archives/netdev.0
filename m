From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 5/5] ethtool: Note common alternate exit condition
 for interrupt coalescing
Date: Tue, 16 Aug 2011 01:09:22 +0100
Message-ID: <1313453362.2731.61.camel@bwh-desktop>
References: <1313453180.2731.57.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eli Cohen <eli@dev.mellanox.co.il>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:41192 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753133Ab1HPAJZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2011 20:09:25 -0400
In-Reply-To: <1313453180.2731.57.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Many implementations ignore the value of max_frames and do not
treat usecs == 0 as special.  Document this as deprecated.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 include/linux/ethtool.h |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 42378b3..3829712 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -173,6 +173,12 @@ struct ethtool_eeprom {
  * would cause interrupts to never be generated.  To disable
  * coalescing, set usecs = 0 and max_frames = 1.
  *
+ * Some implementations ignore the value of max_frames and use the
+ * condition:
+ *	time_since_first_completion >= usecs
+ * This is deprecated.  Drivers for hardware that does not support
+ * counting completions should validate that max_frames == !rx_usecs.
+ *
  * Adaptive RX/TX coalescing is an algorithm implemented by some
  * drivers to improve latency under low packet rates and improve
  * throughput under high packet rates.  Some drivers only implement
-- 
1.7.4.4


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

