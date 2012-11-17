From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next] pch_gbe, ptp_pch: Fix the dependency direction
 between these drivers
Date: Sat, 17 Nov 2012 01:43:36 +0000
Message-ID: <1353116616.2743.87.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Randy Dunlap <rdunlap@xenotime.net>,
	Takahiro Shimizu <tshimizu818@gmail.com>,
	Richard Cochran <richardcochran@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:26189 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753806Ab2KQBnk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2012 20:43:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit a24006ed12616bde1bbdb26868495906a212d8dc ('ptp: Enable clock
drivers along with associated net/PHY drivers') I wrongly made
PTP_1588_CLOCK_PCH depend on PCH_GBE.  The dependency is really the
other way around.  Therefore make PCH_GBE select PTP_1588_CLOCK_PCH
and remove the 'default y' from the latter.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/oki-semi/pch_gbe/Kconfig |    1 +
 drivers/ptp/Kconfig                           |    2 --
 2 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig b/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig
index 00bc4fc..34d05bf 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig
@@ -7,6 +7,7 @@ config PCH_GBE
 	depends on PCI
 	select NET_CORE
 	select MII
+	select PTP_1588_CLOCK_PCH
 	---help---
 	  This is a gigabit ethernet driver for EG20T PCH.
 	  EG20T PCH is the platform controller hub that is used in Intel's
diff --git a/drivers/ptp/Kconfig b/drivers/ptp/Kconfig
index 70c5836..1ea6f1d 100644
--- a/drivers/ptp/Kconfig
+++ b/drivers/ptp/Kconfig
@@ -72,9 +72,7 @@ config DP83640_PHY
 
 config PTP_1588_CLOCK_PCH
 	tristate "Intel PCH EG20T as PTP clock"
-	depends on PCH_GBE
 	select PTP_1588_CLOCK
-	default y
 	help
 	  This driver adds support for using the PCH EG20T as a PTP
 	  clock. The hardware supports time stamping of PTP packets
-- 
1.7.7.6


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
