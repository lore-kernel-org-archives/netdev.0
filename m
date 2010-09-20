From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 3/8] ethtool: Allocate register dump buffer
 with vmalloc()
Date: Mon, 20 Sep 2010 19:42:17 +0100
Message-ID: <1285008137.2282.106.camel@achroite.uk.solarflarecom.com>
References: <1285008056.2282.103.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:7161 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753262Ab0ITSmU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Sep 2010 14:42:20 -0400
In-Reply-To: <1285008056.2282.103.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some NICs have huge register files which exceed the maximum heap
allocation size.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 net/core/ethtool.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 91ffce2..dae2fd0 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -815,7 +815,7 @@ static int ethtool_get_regs(struct net_device *dev, char __user *useraddr)
 	if (regs.len > reglen)
 		regs.len = reglen;
 
-	regbuf = kmalloc(reglen, GFP_USER);
+	regbuf = vmalloc(reglen);
 	if (!regbuf)
 		return -ENOMEM;
 
@@ -830,7 +830,7 @@ static int ethtool_get_regs(struct net_device *dev, char __user *useraddr)
 	ret = 0;
 
  out:
-	kfree(regbuf);
+	vfree(regbuf);
 	return ret;
 }
 
-- 
1.7.2.1



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

