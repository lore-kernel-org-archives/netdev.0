From: Hannes Eder <hannes@hanneseder.net>
Subject: [PATCH 17/27] drivers/net/tokenring: fix sparse warnings: make
	symbols static
Date: Mon, 22 Dec 2008 20:17:27 +0100
Message-ID: <20081222191727.11807.90548.stgit@vmbox.hanneseder.net>
References: <20081222191259.11807.53190.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f21.google.com ([209.85.218.21]:50184 "EHLO
	mail-bw0-f21.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755872AbYLVTRe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2008 14:17:34 -0500
In-Reply-To: <20081222191259.11807.53190.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix this sparse warnings:

  drivers/net/tokenring/ibmtr.c:1840:6: warning: symbol 'tok_rerun' was not declared. Should it be static?
  drivers/net/tokenring/madgemc.c:469:16: warning: symbol 'madgemc_setnselout_pins' was not declared. Should it be static?
  drivers/net/tokenring/proteon.c:286:16: warning: symbol 'proteon_setnselout_pins' was not declared. Should it be static?
  drivers/net/tokenring/skisa.c:303:16: warning: symbol 'sk_isa_setnselout_pins' was not declared. Should it be static?

Signed-off-by: Hannes Eder <hannes@hanneseder.net>
---
 drivers/net/tokenring/ibmtr.c   |    4 ++--
 drivers/net/tokenring/madgemc.c |    2 +-
 drivers/net/tokenring/proteon.c |    2 +-
 drivers/net/tokenring/skisa.c   |    2 +-
 4 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/tokenring/ibmtr.c b/drivers/net/tokenring/ibmtr.c
index 9fd0993..fa7bce6 100644
--- a/drivers/net/tokenring/ibmtr.c
+++ b/drivers/net/tokenring/ibmtr.c
@@ -1837,8 +1837,8 @@ static void ibmtr_reset_timer(struct timer_list *tmr, struct net_device *dev)
 
 /*****************************************************************************/
 
-void tok_rerun(unsigned long dev_addr){
-
+static void tok_rerun(unsigned long dev_addr)
+{
 	struct net_device *dev = (struct net_device *)dev_addr;
 	struct tok_info *ti = netdev_priv(dev);
 
diff --git a/drivers/net/tokenring/madgemc.c b/drivers/net/tokenring/madgemc.c
index 0ba6f0b..917b4d2 100644
--- a/drivers/net/tokenring/madgemc.c
+++ b/drivers/net/tokenring/madgemc.c
@@ -466,7 +466,7 @@ static irqreturn_t madgemc_interrupt(int irq, void *dev_id)
  * zero to leave the TMS NSELOUT bits unaffected.
  *
  */
-unsigned short madgemc_setnselout_pins(struct net_device *dev)
+static unsigned short madgemc_setnselout_pins(struct net_device *dev)
 {
 	unsigned char reg1;
 	struct net_local *tp = netdev_priv(dev);
diff --git a/drivers/net/tokenring/proteon.c b/drivers/net/tokenring/proteon.c
index cd2d62f..b8c955f 100644
--- a/drivers/net/tokenring/proteon.c
+++ b/drivers/net/tokenring/proteon.c
@@ -283,7 +283,7 @@ static void proteon_read_eeprom(struct net_device *dev)
 		dev->dev_addr[i] = proteon_sifreadw(dev, SIFINC) >> 8;
 }
 
-unsigned short proteon_setnselout_pins(struct net_device *dev)
+static unsigned short proteon_setnselout_pins(struct net_device *dev)
 {
 	return 0;
 }
diff --git a/drivers/net/tokenring/skisa.c b/drivers/net/tokenring/skisa.c
index b578744..c0f58f0 100644
--- a/drivers/net/tokenring/skisa.c
+++ b/drivers/net/tokenring/skisa.c
@@ -300,7 +300,7 @@ static void sk_isa_read_eeprom(struct net_device *dev)
 		dev->dev_addr[i] = sk_isa_sifreadw(dev, SIFINC) >> 8;
 }
 
-unsigned short sk_isa_setnselout_pins(struct net_device *dev)
+static unsigned short sk_isa_setnselout_pins(struct net_device *dev)
 {
 	return 0;
 }

