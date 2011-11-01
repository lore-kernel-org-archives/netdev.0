From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 04/21] Fix type of bit-number parameter to
 set_bit() and clear_bit()
Date: Tue, 1 Nov 2011 23:14:43 +0000
Message-ID: <1320189283.2758.34.camel@bwh-desktop>
References: <1320186901.2758.30.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-net-drivers@solarflare.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:37880 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755906Ab1KAXOr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2011 19:14:47 -0400
In-Reply-To: <1320186901.2758.30.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The index must not be negative, so the parameter does not need to be
signed.  Division and modulus on signed operands generally cannot be
optimised to right-shift and bitwise-and.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 internal.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/internal.h b/internal.h
index 693b091..2b6a54a 100644
--- a/internal.h
+++ b/internal.h
@@ -62,12 +62,12 @@ static inline u64 cpu_to_be64(u64 value)
 #define DIV_ROUND_UP(n, d)	(((n) + (d) - 1) / (d))
 #define BITS_TO_LONGS(nr)	DIV_ROUND_UP(nr, BITS_PER_LONG)
 
-static inline void set_bit(int nr, unsigned long *addr)
+static inline void set_bit(unsigned int nr, unsigned long *addr)
 {
 	addr[nr / BITS_PER_LONG] |= 1UL << (nr % BITS_PER_LONG);
 }
 
-static inline void clear_bit(int nr, unsigned long *addr)
+static inline void clear_bit(unsigned int nr, unsigned long *addr)
 {
 	addr[nr / BITS_PER_LONG] &= ~(1UL << (nr % BITS_PER_LONG));
 }
-- 
1.7.4.4



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
