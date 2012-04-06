From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 1/6] ethtool: Remove exception to the requirement
 of holding RTNL lock
Date: Fri, 6 Apr 2012 01:38:49 +0100
Message-ID: <1333672729.2652.23.camel@bwh-desktop.uk.solarflarecom.com>
References: <HEAD <1333672667.2652.22.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:28059 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752951Ab2DFAiw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Apr 2012 20:38:52 -0400
In-Reply-To: <HEAD <1333672667.2652.22.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit e52ac3398c3d772d372b9b62ab408fd5eec96840 ('net: Use device
model to get driver name in skb_gso_segment()') removed the only
in-tree caller of ethtool ops that doesn't hold the RTNL lock.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 include/linux/ethtool.h |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 560a247..89d68d8 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -923,8 +923,7 @@ static inline u32 ethtool_rxfh_indir_default(u32 index, u32 n_rx_rings)
  *
  * All operations are optional (i.e. the function pointer may be set
  * to %NULL) and callers must take this into account.  Callers must
- * hold the RTNL, except that for @get_drvinfo the caller may or may
- * not hold the RTNL.
+ * hold the RTNL lock.
  *
  * See the structures used by these operations for further documentation.
  *
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
