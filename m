From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH] sfc: Fix dependency for SFC_MTD
Date: Wed, 19 Nov 2008 20:48:52 +0000
Message-ID: <20081119204850.GF8240@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	Randy Dunlap <randy.dunlap@oracle.com>,
	David Woodhouse <dwmw2@infradead.org>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:56299 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752882AbYKSUtB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2008 15:49:01 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Randy Dunlap found that SFC_MTD was selected when sfc was built-in and
the MTD core was a module.  Don't allow that combination.
---
 drivers/net/sfc/Kconfig |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sfc/Kconfig b/drivers/net/sfc/Kconfig
index 3e25fb3..c535408 100644
--- a/drivers/net/sfc/Kconfig
+++ b/drivers/net/sfc/Kconfig
@@ -14,7 +14,7 @@ config SFC
 	  will be called sfc.
 config SFC_MTD
 	bool "Solarflare Solarstorm SFC4000 flash MTD support"
-	depends on SFC && MTD
+	depends on SFC && MTD && !(SFC=y && MTD=m)
 	default y
 	help
 	  This exposes the on-board flash memory as an MTD device (e.g.
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
