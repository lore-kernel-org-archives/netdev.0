From: Tim Mann <mann@vmware.com>
Subject: [PATCH 2.6.22-rc4-git6] forcedeth: use unicast receive mode for WoL
Date: Thu, 14 Jun 2007 13:16:38 -0700
Message-ID: <20070614131638.1a5cef4c@mann-lx.eng.vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mann@vmware.com, Andrew Morton <akpm@linux-foundation.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-1.vmware.com ([65.113.40.141]:55361 "EHLO
	smtp-outbound-1.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752139AbXFNUQk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jun 2007 16:16:40 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I happened to notice that a system with an NVidia NIC using the
forcedeth driver won't wake-on-LAN if the interface was in promiscuous
mode when you power off.  By experiment, it looks like
the hardware needs to have NvRegPacketFilterFlags set to
NVREG_PFF_ALWAYS|NVREG_PFF_MYADDR (i.e., receive unicast packets to my
address) in order for WoL to work.

Jeff Garzik writes: "NVIDIA says the patch looks OK."  I didn't venture
to insert a signed-off-by line with his name on it, though.

Signed-off-by: Tim Mann <mann@vmware.com>

---
(Jeff, thanks for pointing me to the doc for the proper patch format.)

--- 2.6.22-rc4-git6/drivers/net/forcedeth.c	2007-06-14 12:56:47.078002000 -0700
+++ 2.6.22-rc4-git6-fixed/drivers/net/forcedeth.c	2007-06-14 12:56:21.200146000 -0700
@@ -4825,8 +4825,10 @@
 
 	drain_ring(dev);
 
-	if (np->wolenabled)
+	if (np->wolenabled) {
+		writel(NVREG_PFF_ALWAYS|NVREG_PFF_MYADDR, base + NvRegPacketFilterFlags);
 		nv_start_rx(dev);
+	}
 
 	/* FIXME: power down nic */
 


-- 
Tim Mann  work: mann@vmware.com  home: tim@tim-mann.org
          http://www.vmware.com  http://tim-mann.org
