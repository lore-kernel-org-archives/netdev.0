From: akpm@linux-foundation.org
Subject: [patch 07/11] pcnet32: fix warning
Date: Wed, 14 May 2008 16:20:14 -0700
Message-ID: <200805142320.m4ENKEAu026629@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:46453 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754315AbYENXUr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2008 19:20:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>

pci_name() will be changed to return `const char *':

drivers/net/pcnet32.c: In function 'pcnet32_probe1':
drivers/net/pcnet32.c:1884: warning: passing argument 2 of 'pcnet32_alloc_ring' discards qualifiers from pointer target type

Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/pcnet32.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff -puN drivers/net/pcnet32.c~pcnet32-fix-warning drivers/net/pcnet32.c
--- a/drivers/net/pcnet32.c~pcnet32-fix-warning
+++ a/drivers/net/pcnet32.c
@@ -325,7 +325,7 @@ static int pcnet32_get_regs_len(struct n
 static void pcnet32_get_regs(struct net_device *dev, struct ethtool_regs *regs,
 			     void *ptr);
 static void pcnet32_purge_tx_ring(struct net_device *dev);
-static int pcnet32_alloc_ring(struct net_device *dev, char *name);
+static int pcnet32_alloc_ring(struct net_device *dev, const char *name);
 static void pcnet32_free_ring(struct net_device *dev);
 static void pcnet32_check_media(struct net_device *dev, int verbose);
 
@@ -1983,7 +1983,7 @@ pcnet32_probe1(unsigned long ioaddr, int
 }
 
 /* if any allocation fails, caller must also call pcnet32_free_ring */
-static int pcnet32_alloc_ring(struct net_device *dev, char *name)
+static int pcnet32_alloc_ring(struct net_device *dev, const char *name)
 {
 	struct pcnet32_private *lp = netdev_priv(dev);
 
_
