From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH 4/4] docbook: make a networking book and fix a few errors
Date: Mon, 11 Feb 2008 17:28:34 -0800
Message-ID: <20080211172834.3e42b9e5.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, davem@davemloft.net,
	akpm <akpm@linux-foundation.org>
To: lkml <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:20471 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756090AbYBLBc7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2008 20:32:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>

Move networking (core and drivers) docbook to its own networking book.
Fix a few kernel-doc errors in header and source files.

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 Documentation/DocBook/Makefile        |    2 
 Documentation/DocBook/kernel-api.tmpl |   65 --------------------
 Documentation/DocBook/networking.tmpl |  106 ++++++++++++++++++++++++++++++++++
 include/linux/etherdevice.h           |    3 
 net/core/dev.c                        |    3 
 net/core/skbuff.c                     |    4 -
 6 files changed, 111 insertions(+), 72 deletions(-)

--- linux-2.6.25-rc1.orig/include/linux/etherdevice.h
+++ linux-2.6.25-rc1/include/linux/etherdevice.h
@@ -70,8 +70,7 @@ static inline int is_multicast_ether_add
 }
 
 /**
- * is_local_ether_addr - Determine if the Ethernet address is locally-assigned
- * one (IEEE 802).
+ * is_local_ether_addr - Determine if the Ethernet address is locally-assigned one (IEEE 802).
  * @addr: Pointer to a six-byte array containing the Ethernet address
  *
  * Return true if the address is a local address.
--- linux-2.6.25-rc1.orig/net/core/dev.c
+++ linux-2.6.25-rc1/net/core/dev.c
@@ -3038,8 +3038,7 @@ int dev_unicast_sync(struct net_device *
 EXPORT_SYMBOL(dev_unicast_sync);
 
 /**
- *	dev_unicast_unsync - Remove synchronized addresses from the destination
- *			     device
+ *	dev_unicast_unsync - Remove synchronized addresses from the destination device
  *	@to: destination device
  *	@from: source device
  *
--- linux-2.6.25-rc1.orig/net/core/skbuff.c
+++ linux-2.6.25-rc1/net/core/skbuff.c
@@ -1907,11 +1907,11 @@ void skb_prepare_seq_read(struct sk_buff
  * of bytes already consumed and the next call to
  * skb_seq_read() will return the remaining part of the block.
  *
- * Note: The size of each block of data returned can be arbitary,
+ * Note 1: The size of each block of data returned can be arbitary,
  *       this limitation is the cost for zerocopy seqeuental
  *       reads of potentially non linear data.
  *
- * Note: Fragment lists within fragments are not implemented
+ * Note 2: Fragment lists within fragments are not implemented
  *       at the moment, state->root_skb could be replaced with
  *       a stack for this purpose.
  */
--- linux-2.6.25-rc1.orig/Documentation/DocBook/Makefile
+++ linux-2.6.25-rc1/Documentation/DocBook/Makefile
@@ -8,7 +8,7 @@
 
 DOCBOOKS := wanbook.xml z8530book.xml mcabook.xml videobook.xml \
 	    kernel-hacking.xml kernel-locking.xml deviceiobook.xml \
-	    procfs-guide.xml writing_usb_driver.xml \
+	    procfs-guide.xml writing_usb_driver.xml networking.xml \
 	    kernel-api.xml filesystems.xml lsm.xml usb.xml \
 	    gadget.xml libata.xml mtdnand.xml librs.xml rapidio.xml \
 	    genericirq.xml s390-drivers.xml uio-howto.xml scsi.xml
--- /dev/null
+++ linux-2.6.25-rc1/Documentation/DocBook/networking.tmpl
@@ -0,0 +1,106 @@
+<?xml version="1.0" encoding="UTF-8"?>
+<!DOCTYPE book PUBLIC "-//OASIS//DTD DocBook XML V4.1.2//EN"
+	"http://www.oasis-open.org/docbook/xml/4.1.2/docbookx.dtd" []>
+
+<book id="LinuxNetworking">
+ <bookinfo>
+  <title>Linux Networking and Network Devices APIs</title>
+
+  <legalnotice>
+   <para>
+     This documentation is free software; you can redistribute
+     it and/or modify it under the terms of the GNU General Public
+     License as published by the Free Software Foundation; either
+     version 2 of the License, or (at your option) any later
+     version.
+   </para>
+
+   <para>
+     This program is distributed in the hope that it will be
+     useful, but WITHOUT ANY WARRANTY; without even the implied
+     warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
+     See the GNU General Public License for more details.
+   </para>
+
+   <para>
+     You should have received a copy of the GNU General Public
+     License along with this program; if not, write to the Free
+     Software Foundation, Inc., 59 Temple Place, Suite 330, Boston,
+     MA 02111-1307 USA
+   </para>
+
+   <para>
+     For more details see the file COPYING in the source
+     distribution of Linux.
+   </para>
+  </legalnotice>
+ </bookinfo>
+
+<toc></toc>
+
+  <chapter id="netcore">
+     <title>Linux Networking</title>
+     <sect1><title>Networking Base Types</title>
+!Iinclude/linux/net.h
+     </sect1>
+     <sect1><title>Socket Buffer Functions</title>
+!Iinclude/linux/skbuff.h
+!Iinclude/net/sock.h
+!Enet/socket.c
+!Enet/core/skbuff.c
+!Enet/core/sock.c
+!Enet/core/datagram.c
+!Enet/core/stream.c
+     </sect1>
+     <sect1><title>Socket Filter</title>
+!Enet/core/filter.c
+     </sect1>
+     <sect1><title>Generic Network Statistics</title>
+!Iinclude/linux/gen_stats.h
+!Enet/core/gen_stats.c
+!Enet/core/gen_estimator.c
+     </sect1>
+     <sect1><title>SUN RPC subsystem</title>
+<!-- The !D functionality is not perfect, garbage has to be protected by comments
+!Dnet/sunrpc/sunrpc_syms.c
+-->
+!Enet/sunrpc/xdr.c
+!Enet/sunrpc/svc_xprt.c
+!Enet/sunrpc/xprt.c
+!Enet/sunrpc/sched.c
+!Enet/sunrpc/socklib.c
+!Enet/sunrpc/stats.c
+!Enet/sunrpc/rpc_pipe.c
+!Enet/sunrpc/rpcb_clnt.c
+!Enet/sunrpc/clnt.c
+     </sect1>
+  </chapter>
+
+  <chapter id="netdev">
+     <title>Network device support</title>
+     <sect1><title>Driver Support</title>
+!Enet/core/dev.c
+!Enet/ethernet/eth.c
+!Enet/sched/sch_generic.c
+!Iinclude/linux/etherdevice.h
+!Iinclude/linux/netdevice.h
+     </sect1>
+     <sect1><title>PHY Support</title>
+!Edrivers/net/phy/phy.c
+!Idrivers/net/phy/phy.c
+!Edrivers/net/phy/phy_device.c
+!Idrivers/net/phy/phy_device.c
+!Edrivers/net/phy/mdio_bus.c
+!Idrivers/net/phy/mdio_bus.c
+     </sect1>
+<!-- FIXME: Removed for now since no structured comments in source
+     <sect1><title>Wireless</title>
+X!Enet/core/wireless.c
+     </sect1>
+-->
+     <sect1><title>Synchronous PPP</title>
+!Edrivers/net/wan/syncppp.c
+     </sect1>
+  </chapter>
+
+</book>
--- linux-2.6.25-rc1.orig/Documentation/DocBook/kernel-api.tmpl
+++ linux-2.6.25-rc1/Documentation/DocBook/kernel-api.tmpl
@@ -204,71 +204,6 @@ X!Ilib/string.c
      </sect1>
   </chapter>
 
-  <chapter id="netcore">
-     <title>Linux Networking</title>
-     <sect1><title>Networking Base Types</title>
-!Iinclude/linux/net.h
-     </sect1>
-     <sect1><title>Socket Buffer Functions</title>
-!Iinclude/linux/skbuff.h
-!Iinclude/net/sock.h
-!Enet/socket.c
-!Enet/core/skbuff.c
-!Enet/core/sock.c
-!Enet/core/datagram.c
-!Enet/core/stream.c
-     </sect1>
-     <sect1><title>Socket Filter</title>
-!Enet/core/filter.c
-     </sect1>
-     <sect1><title>Generic Network Statistics</title>
-!Iinclude/linux/gen_stats.h
-!Enet/core/gen_stats.c
-!Enet/core/gen_estimator.c
-     </sect1>
-     <sect1><title>SUN RPC subsystem</title>
-<!-- The !D functionality is not perfect, garbage has to be protected by comments
-!Dnet/sunrpc/sunrpc_syms.c
--->
-!Enet/sunrpc/xdr.c
-!Enet/sunrpc/svc_xprt.c
-!Enet/sunrpc/xprt.c
-!Enet/sunrpc/sched.c
-!Enet/sunrpc/socklib.c
-!Enet/sunrpc/stats.c
-!Enet/sunrpc/rpc_pipe.c
-!Enet/sunrpc/rpcb_clnt.c
-!Enet/sunrpc/clnt.c
-     </sect1>
-  </chapter>
-
-  <chapter id="netdev">
-     <title>Network device support</title>
-     <sect1><title>Driver Support</title>
-!Enet/core/dev.c
-!Enet/ethernet/eth.c
-!Enet/sched/sch_generic.c
-!Iinclude/linux/etherdevice.h
-!Iinclude/linux/netdevice.h
-     </sect1>
-     <sect1><title>PHY Support</title>
-!Edrivers/net/phy/phy.c
-!Idrivers/net/phy/phy.c
-!Edrivers/net/phy/phy_device.c
-!Idrivers/net/phy/phy_device.c
-!Edrivers/net/phy/mdio_bus.c
-!Idrivers/net/phy/mdio_bus.c
-     </sect1>
-<!-- FIXME: Removed for now since no structured comments in source
-     <sect1><title>Wireless</title>
-X!Enet/core/wireless.c
-     </sect1>
--->
-     <sect1><title>Synchronous PPP</title>
-!Edrivers/net/wan/syncppp.c
-     </sect1>
-  </chapter>
-
   <chapter id="modload">
      <title>Module Support</title>
      <sect1><title>Module Loading</title>
