From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 1/3] ethtool: Clarify use of size field for
 ETHTOOL_GRXFHINDIR
Date: Thu, 15 Dec 2011 23:51:16 +0000
Message-ID: <1323993076.2773.23.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	Matt Carlson <mcarlson@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:34801 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1759860Ab1LOXvT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Dec 2011 18:51:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to find out the device's RX flow hash table size, ethtool
initially uses ETHTOOL_GRXFHINDIR with a buffer size of zero.  This
must be supported, but it is not necessary to support any other user
buffer size less than the device table size.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 include/linux/ethtool.h |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 20db5b27..0ec2fd4 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -543,8 +543,9 @@ struct compat_ethtool_rxnfc {
 /**
  * struct ethtool_rxfh_indir - command to get or set RX flow hash indirection
  * @cmd: Specific command number - %ETHTOOL_GRXFHINDIR or %ETHTOOL_SRXFHINDIR
- * @size: On entry, the array size of the user buffer.  On return from
- *	%ETHTOOL_GRXFHINDIR, the array size of the hardware indirection table.
+ * @size: On entry, the array size of the user buffer, which may be zero
+ *	for %ETHTOOL_GRXFHINDIR.  On return from %ETHTOOL_GRXFHINDIR, the
+ *	array size of the hardware indirection table.
  * @ring_index: RX ring/queue index for each hash value
  */
 struct ethtool_rxfh_indir {
-- 
1.7.4.4



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
