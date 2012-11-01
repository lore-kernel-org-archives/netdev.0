From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 1/3] pps, ptp: Remove dependencies on EXPERIMENTAL
Date: Thu, 1 Nov 2012 01:31:29 +0000
Message-ID: <1351733489.2706.63.camel@bwh-desktop.uk.solarflarecom.com>
References: <1351733397.2706.62.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>,
	Rodolfo Giometti <giometti@enneenne.com>,
	Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:64004 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757002Ab2KABbc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2012 21:31:32 -0400
In-Reply-To: <1351733397.2706.62.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These are now established subsystems, and we want drivers to be able
to select PPS and PTP_1588_CLOCK without depending on EXPERIMENTAL.
Further, the use of EXPERIMENTAL is now deprecated in general.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/intel/Kconfig            |    4 ++--
 drivers/net/ethernet/oki-semi/pch_gbe/Kconfig |    1 -
 drivers/pps/Kconfig                           |    1 -
 drivers/ptp/Kconfig                           |    1 -
 4 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/Kconfig b/drivers/net/ethernet/intel/Kconfig
index 0cafe4f..9e49217 100644
--- a/drivers/net/ethernet/intel/Kconfig
+++ b/drivers/net/ethernet/intel/Kconfig
@@ -123,7 +123,7 @@ config IGB_DCA
 config IGB_PTP
 	bool "PTP Hardware Clock (PHC)"
 	default n
-	depends on IGB && EXPERIMENTAL
+	depends on IGB
 	select PPS
 	select PTP_1588_CLOCK
 	---help---
@@ -225,7 +225,7 @@ config IXGBE_DCB
 config IXGBE_PTP
 	bool "PTP Clock Support"
 	default n
-	depends on IXGBE && EXPERIMENTAL
+	depends on IXGBE
 	select PPS
 	select PTP_1588_CLOCK
 	---help---
diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig b/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig
index 5296cc8..9867bc6 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig
@@ -26,7 +26,6 @@ if PCH_GBE
 config PCH_PTP
 	bool "PCH PTP clock support"
 	default n
-	depends on EXPERIMENTAL
 	select PPS
 	select PTP_1588_CLOCK
 	select PTP_1588_CLOCK_PCH
diff --git a/drivers/pps/Kconfig b/drivers/pps/Kconfig
index 258ca59..982d16b 100644
--- a/drivers/pps/Kconfig
+++ b/drivers/pps/Kconfig
@@ -6,7 +6,6 @@ menu "PPS support"
 
 config PPS
 	tristate "PPS support"
-	depends on EXPERIMENTAL
 	---help---
 	  PPS (Pulse Per Second) is a special pulse provided by some GPS
 	  antennae. Userland can use it to get a high-precision time
diff --git a/drivers/ptp/Kconfig b/drivers/ptp/Kconfig
index ffdf712..a6e4b7c 100644
--- a/drivers/ptp/Kconfig
+++ b/drivers/ptp/Kconfig
@@ -9,7 +9,6 @@ comment "Enable Device Drivers -> PPS to see the PTP clock options."
 
 config PTP_1588_CLOCK
 	tristate "PTP clock support"
-	depends on EXPERIMENTAL
 	depends on PPS
 	help
 	  The IEEE 1588 standard defines a method to precisely
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
