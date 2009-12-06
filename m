From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH] Remove deprecated print_mac to fix warnings
Date: Sun, 6 Dec 2009 15:08:28 +0100
Message-ID: <20091206140828.GA8600@basil.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:59672 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932286AbZLFOIX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Dec 2009 09:08:23 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove deprecated and unused print_mac to fix warnings

There seems to be no user in tree of print_mac left. So just remove it.

This eliminates two compiler warnings for every build, because gcc
complains about the deprecated use of the symbol in its EXPORT_SYMBOL.

Signed-off-by: Andi Kleen <ak@linux.intel.com>

---
 include/linux/if_ether.h |    1 -
 net/ethernet/eth.c       |    7 -------
 2 files changed, 8 deletions(-)

Index: linux-2.6.32-ak/include/linux/if_ether.h
===================================================================
--- linux-2.6.32-ak.orig/include/linux/if_ether.h
+++ linux-2.6.32-ak/include/linux/if_ether.h
@@ -139,7 +139,6 @@ extern ssize_t sysfs_format_mac(char *bu
 /*
  *	Display a 6 byte device address (MAC) in a readable format.
  */
-extern char *print_mac(char *buf, const unsigned char *addr) __deprecated;
 #define MAC_FMT "%02x:%02x:%02x:%02x:%02x:%02x"
 #define MAC_BUF_SIZE	18
 #define DECLARE_MAC_BUF(var) char var[MAC_BUF_SIZE]
Index: linux-2.6.32-ak/net/ethernet/eth.c
===================================================================
--- linux-2.6.32-ak.orig/net/ethernet/eth.c
+++ linux-2.6.32-ak/net/ethernet/eth.c
@@ -393,10 +393,3 @@ ssize_t sysfs_format_mac(char *buf, cons
 	return ((ssize_t) l);
 }
 EXPORT_SYMBOL(sysfs_format_mac);
-
-char *print_mac(char *buf, const unsigned char *addr)
-{
-	_format_mac_addr(buf, MAC_BUF_SIZE, addr, ETH_ALEN);
-	return buf;
-}
-EXPORT_SYMBOL(print_mac);
