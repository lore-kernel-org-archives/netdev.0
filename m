From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: [net-next PATCH] net: fix endian check warning in etherdevice.h
Date: Thu, 13 Aug 2015 18:34:03 -0700
Message-ID: <20150814013403.20350.45692.stgit@jbrandeb-hsm1.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:60154 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751952AbbHNBeF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Aug 2015 21:34:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sparse builds have been warning for a really long time now
that etherdevice.h has a conversion that is unsafe.

  include/linux/etherdevice.h:79:32: warning: restricted __be16 degrades to integer

This code change fixes the issue and generates the exact
same assembly before/after (checked on x86_64)

Fixes: 2c722fe1c821 (etherdevice: Optimize a few is_<foo>_ether_addr functions)
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
CC: Joe Perches <joe@perches.com>
---
 include/linux/etherdevice.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
index 9012f87..eb049c6 100644
--- a/include/linux/etherdevice.h
+++ b/include/linux/etherdevice.h
@@ -76,7 +76,7 @@ static inline bool is_link_local_ether_addr(const u8 *addr)
 
 #if defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS)
 	return (((*(const u32 *)addr) ^ (*(const u32 *)b)) |
-		((a[2] ^ b[2]) & m)) == 0;
+		(__force int)((a[2] ^ b[2]) & m)) == 0;
 #else
 	return ((a[0] ^ b[0]) | (a[1] ^ b[1]) | ((a[2] ^ b[2]) & m)) == 0;
 #endif
