From: Hannes Eder <hannes@hanneseder.net>
Subject: [PATCH 30/43] drivers/net/tokenring: fix sparse warning: symbol
	shadows an earlier one
Date: Sat, 14 Feb 2009 22:44:44 +0100
Message-ID: <20090214214426.24377.61106.stgit@vmbox.hanneseder.net>
References: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f25.google.com ([209.85.220.25]:45972 "EHLO
	mail-fx0-f25.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752477AbZBNVot (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Feb 2009 16:44:49 -0500
In-Reply-To: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Impact: Remove redundant variables.

Fix this sparse warnings:
  drivers/net/tokenring/lanstreamer.c:619:21: warning: symbol 'i' shadows an earlier one
  drivers/net/tokenring/lanstreamer.c:589:13: originally declared here
  drivers/net/tokenring/madgemc.c:695:34: warning: symbol 'tp' shadows an earlier one
  drivers/net/tokenring/madgemc.c:689:26: originally declared here
  drivers/net/tokenring/olympic.c:702:21: warning: symbol 'i' shadows an earlier one
  drivers/net/tokenring/olympic.c:440:13: originally declared here

Signed-off-by: Hannes Eder <hannes@hanneseder.net>
---
 drivers/net/tokenring/lanstreamer.c |    2 --
 drivers/net/tokenring/madgemc.c     |    2 --
 drivers/net/tokenring/olympic.c     |    1 -
 3 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/drivers/net/tokenring/lanstreamer.c b/drivers/net/tokenring/lanstreamer.c
index 0b2b792..f309b8f 100644
--- a/drivers/net/tokenring/lanstreamer.c
+++ b/drivers/net/tokenring/lanstreamer.c
@@ -616,8 +616,6 @@ static int streamer_open(struct net_device *dev)
 	printk("SISR Mask = %04x\n", readw(streamer_mmio + SISR_MASK));
 #endif
 	do {
-		int i;
-
 		for (i = 0; i < SRB_COMMAND_SIZE; i += 2) {
 			writew(0, streamer_mmio + LAPDINC);
 		}
diff --git a/drivers/net/tokenring/madgemc.c b/drivers/net/tokenring/madgemc.c
index 917b4d2..1933081 100644
--- a/drivers/net/tokenring/madgemc.c
+++ b/drivers/net/tokenring/madgemc.c
@@ -692,8 +692,6 @@ static int madgemc_mcaproc(char *buf, int slot, void *d)
 	
 	len += sprintf(buf+len, "-------\n");
 	if (curcard) {
-		struct net_local *tp = netdev_priv(dev);
-		
 		len += sprintf(buf+len, "Card Revision: %d\n", curcard->cardrev);
 		len += sprintf(buf+len, "RAM Size: %dkb\n", curcard->ramsize);
 		len += sprintf(buf+len, "Cable type: %s\n", (curcard->cabletype)?"STP/DB9":"UTP/RJ-45");
diff --git a/drivers/net/tokenring/olympic.c b/drivers/net/tokenring/olympic.c
index 77dc9da..d068a9d 100644
--- a/drivers/net/tokenring/olympic.c
+++ b/drivers/net/tokenring/olympic.c
@@ -699,7 +699,6 @@ static int olympic_open(struct net_device *dev)
 	if (olympic_priv->olympic_network_monitor) { 
 		u8 __iomem *oat;
 		u8 __iomem *opt;
-		int i;
 		u8 addr[6];
 		oat = (olympic_priv->olympic_lap + olympic_priv->olympic_addr_table_addr);
 		opt = (olympic_priv->olympic_lap + olympic_priv->olympic_parms_addr);

