From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [RFC] [PATCH] ethtool: Flags for fibre speed switching
Date: Mon, 14 Jun 2010 20:26:02 +0100
Message-ID: <1276543562.2074.41.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@redhat.com>,
	sf-linux-drivers <linux-net-drivers@solarflare.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:31945 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753513Ab0FNT0H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jun 2010 15:26:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ethtool.h currently defines only SUPPORTED_FIBRE to cover all fibre
modes.  However, SFP+ slots support both 1G and 10G fibre modules and
some modules are dual-speed.  Some drivers use the BASE-T flags for SFP+
modules of all media types, but this is strictly incorrect and can be
confusing as there are real BASE-T modules for SFP+.  There should be
distinct flags for fibre modes.  However I'm not sure whether it's worth
defining flags for each fibre mode (there are quite a few) or only for
each speed.

Similarly there is only ADVERTISED_FIBRE to cover all fibre modes.
Although there is no AN protocol for fibre, an SFP+ NIC effectively
autonegotiates its speed with the module.  By default, an SFP+ NIC will
accept both 1G and 10G modules and switch speed automatically.  With a
dual-speed module, the NIC driver can allow forcing the speed through
ethtool, but unless it maintains some hidden state it must reset the
speed whenever the module is hotplugged (perhaps accidentally).  So it
should be possible for the administrator to control speed selection in a
sticky way through the advertising mask.

Ben.

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 2c8af09..e3decb9 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -664,6 +664,9 @@ struct ethtool_ops {
 #define SUPPORTED_10000baseKX4_Full	(1 << 18)
 #define SUPPORTED_10000baseKR_Full	(1 << 19)
 #define SUPPORTED_10000baseR_FEC	(1 << 20)
+#define SUPPORTED_1000_FIBRE		(1 << 21)
+#define SUPPORTED_10000_FIBRE		(1 << 22)
+#define SUPPORTED_40000_FIBRE		(1 << 23)
 
 /* Indicates what features are advertised by the interface. */
 #define ADVERTISED_10baseT_Half		(1 << 0)
@@ -687,6 +690,9 @@ struct ethtool_ops {
 #define ADVERTISED_10000baseKX4_Full	(1 << 18)
 #define ADVERTISED_10000baseKR_Full	(1 << 19)
 #define ADVERTISED_10000baseR_FEC	(1 << 20)
+#define ADVERTISED_1000_FIBRE		(1 << 21)
+#define ADVERTISED_10000_FIBRE		(1 << 22)
+#define ADVERTISED_40000_FIBRE		(1 << 23)
 
 /* The following are all involved in forcing a particular link
  * mode for the device for setting things.  When getting the

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

