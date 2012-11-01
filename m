From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 2/3] ptp: Make PTP_1588_CLOCK select rather than
 depend on PPS
Date: Thu, 1 Nov 2012 01:32:44 +0000
Message-ID: <1351733564.2706.64.camel@bwh-desktop.uk.solarflarecom.com>
References: <1351733397.2706.62.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>,
	Rodolfo Giometti <giometti@enneenne.com>,
	Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:64022 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1761208Ab2KABcs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2012 21:32:48 -0400
In-Reply-To: <1351733397.2706.62.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PTP hardware clock drivers that select PTP_1588_CLOCK must currently
also select PPS.  For those drivers that don't, the user must enable
PPS, then enable PTP_1588_CLOCK, then the driver.  Simplify things for
developers and users by putting this selection in one place.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/intel/Kconfig            |    2 --
 drivers/net/ethernet/oki-semi/pch_gbe/Kconfig |    1 -
 drivers/ptp/Kconfig                           |    5 +----
 3 files changed, 1 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/Kconfig b/drivers/net/ethernet/intel/Kconfig
index 9e49217..d5b359d 100644
--- a/drivers/net/ethernet/intel/Kconfig
+++ b/drivers/net/ethernet/intel/Kconfig
@@ -124,7 +124,6 @@ config IGB_PTP
 	bool "PTP Hardware Clock (PHC)"
 	default n
 	depends on IGB
-	select PPS
 	select PTP_1588_CLOCK
 	---help---
 	  Say Y here if you want to use PTP Hardware Clock (PHC) in the
@@ -226,7 +225,6 @@ config IXGBE_PTP
 	bool "PTP Clock Support"
 	default n
 	depends on IXGBE
-	select PPS
 	select PTP_1588_CLOCK
 	---help---
 	  Say Y here if you want support for 1588 Timestamping with a
diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig b/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig
index 9867bc6..d0e36f2 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig
@@ -26,7 +26,6 @@ if PCH_GBE
 config PCH_PTP
 	bool "PCH PTP clock support"
 	default n
-	select PPS
 	select PTP_1588_CLOCK
 	select PTP_1588_CLOCK_PCH
 	---help---
diff --git a/drivers/ptp/Kconfig b/drivers/ptp/Kconfig
index a6e4b7c..131ef03 100644
--- a/drivers/ptp/Kconfig
+++ b/drivers/ptp/Kconfig
@@ -4,12 +4,9 @@
 
 menu "PTP clock support"
 
-comment "Enable Device Drivers -> PPS to see the PTP clock options."
-	depends on PPS=n
-
 config PTP_1588_CLOCK
 	tristate "PTP clock support"
-	depends on PPS
+	select PPS
 	help
 	  The IEEE 1588 standard defines a method to precisely
 	  synchronize distributed clocks over Ethernet networks. The
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
