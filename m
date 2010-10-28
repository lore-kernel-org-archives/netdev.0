From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix missing dependency of PCH_GBE driver
Date: Thu, 28 Oct 2010 10:16:18 -0700 (PDT)
Message-ID: <20101028.101618.226776102.davem@davemloft.net>
References: <1288268189.18238.173.camel@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	error27@gmail.com, masa-korg@dsn.okisemi.com,
	akpm@linux-foundation.org
To: rostedt@goodmis.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45535
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933964Ab0J1RP4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 13:15:56 -0400
In-Reply-To: <1288268189.18238.173.camel@gandalf.stny.rr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steven Rostedt <rostedt@goodmis.org>
Date: Thu, 28 Oct 2010 08:16:29 -0400

> While doing some randconfigs I stumbled across this build error:
> 
> ERROR: "mii_ethtool_gset" [drivers/net/pch_gbe/pch_gbe.ko] undefined!
> ERROR: "generic_mii_ioctl" [drivers/net/pch_gbe/pch_gbe.ko] undefined!
> ERROR: "mii_nway_restart" [drivers/net/pch_gbe/pch_gbe.ko] undefined!
> ERROR: "mii_check_gmii_support" [drivers/net/pch_gbe/pch_gbe.ko] undefined!
> ERROR: "mii_link_ok" [drivers/net/pch_gbe/pch_gbe.ko] undefined!
> ERROR: "mii_ethtool_sset" [drivers/net/pch_gbe/pch_gbe.ko] undefined!
> 
> The config option PCH_GBE is missing the dependency of MII.
> 
> Signed-off-by: Steven Rostedt <rostedt@goodmis.org>

The canonical way to handle this is to use 'select'.  Thus,
I've committed the following to fix this.

Thanks.

--------------------
pch_gbe: Select MII.

Reported-by: Steven Rostedt <rostedt@goodmis.org>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/Kconfig |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 77c1fab..f24179d 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2520,6 +2520,7 @@ source "drivers/net/stmmac/Kconfig"
 config PCH_GBE
 	tristate "PCH Gigabit Ethernet"
 	depends on PCI
+	select MII
 	---help---
 	  This is a gigabit ethernet driver for Topcliff PCH.
 	  Topcliff PCH is the platform controller hub that is used in Intel's
-- 
1.7.3.2

