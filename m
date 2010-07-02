From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-2.6] net: Fix definition of netif_vdbg() when
 VERBOSE_DEBUG is defined
Date: Fri, 02 Jul 2010 18:08:44 +0100
Message-ID: <1278090524.2095.41.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	Joe Perches <joe@perches.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:41609 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751025Ab0GBRIs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jul 2010 13:08:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netif_vdbg() was originally defined as entirely equivalent to
netdev_vdbg(), but I assume that it was intended to take the same
parameters as netif_dbg() etc.  (Currently it is only used by the
sfc driver, in which I worked on that assumption.)

In commit a4ed89c I changed the definition used when VERBOSE_DEBUG is
not defined, but I failed to notice that the definition used when
VERBOSE_DEBUG is defined was also not as I expected.  Change that to
match netif_dbg() as well.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
Since there are no users of this macro in net-2.6, this should be safe
to change.  If you don't want to make this change in net-2.6 then please
revert a4ed89c in net-2.6 and apply this in net-next-2.6 so that the two
alternate definitions are consistent in each tree.

Ben.

 include/linux/netdevice.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 8fa5e5a..f823fd8 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2352,7 +2352,7 @@ do {								\
 #endif
 
 #if defined(VERBOSE_DEBUG)
-#define netif_vdbg	netdev_dbg
+#define netif_vdbg	netif_dbg
 #else
 #define netif_vdbg(priv, type, dev, format, args...)		\
 ({								\
-- 
1.6.2.5

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

