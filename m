From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: e1000: include <net/ip6_checksum.h> for IA64
Date: Wed, 08 Nov 2006 09:48:35 -0800
Message-ID: <45521873.20402@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, NetDev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:23858 "EHLO mga02.intel.com")
	by vger.kernel.org with ESMTP id S1161382AbWKHRs7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Nov 2006 12:48:59 -0500
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Here's a slightly better patch to fix ia64 not building atm.

Jeff, please apply this to netdev-2.6#upstream instead of akpm's patch that I acked earlier.

Of course, someone really should come up with an asm version for ia64 of the missing 
function ;)

Cheers,

Auke

---

e1000: include <net/ip6_checksum.h> for IA64

IA64 does not have an optimized asm version for ipv6 csum magic. Fall
back to generic implementation.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>

diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
index f091042..26e7506 100644
--- a/drivers/net/e1000/e1000.h
+++ b/drivers/net/e1000/e1000.h
@@ -61,6 +61,7 @@
  #include <linux/ip.h>
  #ifdef NETIF_F_TSO6
  #include <linux/ipv6.h>
+#include <net/ip6_checksum.h>
  #endif
  #include <linux/tcp.h>
  #include <linux/udp.h>
