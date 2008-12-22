From: Hannes Eder <hannes@hanneseder.net>
Subject: [PATCH 12/27] drivers/net/irda: fix sparse warnings: make symbols
	static
Date: Mon, 22 Dec 2008 20:16:41 +0100
Message-ID: <20081222191641.11807.72534.stgit@vmbox.hanneseder.net>
References: <20081222191259.11807.53190.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.157]:25434 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755635AbYLVTQs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2008 14:16:48 -0500
In-Reply-To: <20081222191259.11807.53190.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix this sparse warnings:

  drivers/net/irda/ma600-sir.c:239:5: warning: symbol 'ma600_reset' was not declared. Should it be static?
  drivers/net/irda/smsc-ircc2.c:875:5: warning: symbol 'smsc_ircc_hard_xmit_sir' was not declared. Should it be static?
  drivers/net/irda/smsc-ircc2.c:1131:6: warning: symbol 'smsc_ircc_set_sir_speed' was not declared. Should it be static?
  drivers/net/irda/smsc-ircc2.c:1897:6: warning: symbol 'smsc_ircc_sir_start' was not declared. Should it be static?
  drivers/net/irda/w83977af_ir.c:150:5: warning: symbol 'w83977af_open' was not declared. Should it be static?
  drivers/net/irda/w83977af_ir.c:313:5: warning: symbol 'w83977af_probe' was not declared. Should it be static?
  drivers/net/irda/w83977af_ir.c:412:6: warning: symbol 'w83977af_change_speed' was not declared. Should it be static?
  drivers/net/irda/w83977af_ir.c:492:5: warning: symbol 'w83977af_hard_xmit' was not declared. Should it be static?
  drivers/net/irda/w83977af_ir.c:734:5: warning: symbol 'w83977af_dma_receive' was not declared. Should it be static?
  drivers/net/irda/w83977af_ir.c:806:5: warning: symbol 'w83977af_dma_receive_complete' was not declared. Should it be static?

Signed-off-by: Hannes Eder <hannes@hanneseder.net>
---
 drivers/net/irda/ma600-sir.c   |    2 +-
 drivers/net/irda/smsc-ircc2.c  |    6 +++---
 drivers/net/irda/w83977af_ir.c |   14 +++++++-------
 3 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/net/irda/ma600-sir.c b/drivers/net/irda/ma600-sir.c
index 1ceed9c..e912164 100644
--- a/drivers/net/irda/ma600-sir.c
+++ b/drivers/net/irda/ma600-sir.c
@@ -236,7 +236,7 @@ static int ma600_change_speed(struct sir_dev *dev, unsigned speed)
  * avoid the state machine complexity before we get things working
  */
 
-int ma600_reset(struct sir_dev *dev)
+static int ma600_reset(struct sir_dev *dev)
 {
 	IRDA_DEBUG(2, "%s()\n", __func__);
 
diff --git a/drivers/net/irda/smsc-ircc2.c b/drivers/net/irda/smsc-ircc2.c
index b5360fe..5d09e15 100644
--- a/drivers/net/irda/smsc-ircc2.c
+++ b/drivers/net/irda/smsc-ircc2.c
@@ -872,7 +872,7 @@ static void smsc_ircc_timeout(struct net_device *dev)
  *    waits until the next transmit interrupt, and continues until the
  *    frame is transmitted.
  */
-int smsc_ircc_hard_xmit_sir(struct sk_buff *skb, struct net_device *dev)
+static int smsc_ircc_hard_xmit_sir(struct sk_buff *skb, struct net_device *dev)
 {
 	struct smsc_ircc_cb *self;
 	unsigned long flags;
@@ -1128,7 +1128,7 @@ static void smsc_ircc_change_speed(struct smsc_ircc_cb *self, u32 speed)
  *    Set speed of IrDA port to specified baudrate
  *
  */
-void smsc_ircc_set_sir_speed(struct smsc_ircc_cb *self, __u32 speed)
+static void smsc_ircc_set_sir_speed(struct smsc_ircc_cb *self, __u32 speed)
 {
 	int iobase;
 	int fcr;    /* FIFO control reg */
@@ -1894,7 +1894,7 @@ static void __exit smsc_ircc_cleanup(void)
  * This function *must* be called with spinlock held, because it may
  * be called from the irq handler (via smsc_ircc_change_speed()). - Jean II
  */
-void smsc_ircc_sir_start(struct smsc_ircc_cb *self)
+static void smsc_ircc_sir_start(struct smsc_ircc_cb *self)
 {
 	struct net_device *dev;
 	int fir_base, sir_base;
diff --git a/drivers/net/irda/w83977af_ir.c b/drivers/net/irda/w83977af_ir.c
index 161d591..30ec913 100644
--- a/drivers/net/irda/w83977af_ir.c
+++ b/drivers/net/irda/w83977af_ir.c
@@ -147,8 +147,8 @@ static void __exit w83977af_cleanup(void)
  *    Open driver instance
  *
  */
-int w83977af_open(int i, unsigned int iobase, unsigned int irq, 
-		  unsigned int dma)
+static int w83977af_open(int i, unsigned int iobase, unsigned int irq,
+			 unsigned int dma)
 {
 	struct net_device *dev;
         struct w83977af_ir *self;
@@ -310,7 +310,7 @@ static int w83977af_close(struct w83977af_ir *self)
 	return 0;
 }
 
-int w83977af_probe( int iobase, int irq, int dma)
+static int w83977af_probe(int iobase, int irq, int dma)
 {
   	int version;
 	int i;
@@ -409,7 +409,7 @@ int w83977af_probe( int iobase, int irq, int dma)
 	return -1;
 }
 
-void w83977af_change_speed(struct w83977af_ir *self, __u32 speed)
+static void w83977af_change_speed(struct w83977af_ir *self, __u32 speed)
 {
 	int ir_mode = HCR_SIR;
 	int iobase; 
@@ -489,7 +489,7 @@ void w83977af_change_speed(struct w83977af_ir *self, __u32 speed)
  *    Sets up a DMA transfer to send the current frame.
  *
  */
-int w83977af_hard_xmit(struct sk_buff *skb, struct net_device *dev)
+static int w83977af_hard_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct w83977af_ir *self;
 	__s32 speed;
@@ -731,7 +731,7 @@ static void w83977af_dma_xmit_complete(struct w83977af_ir *self)
  *    if it starts to receive a frame.
  *
  */
-int w83977af_dma_receive(struct w83977af_ir *self) 
+static int w83977af_dma_receive(struct w83977af_ir *self)
 {
 	int iobase;
 	__u8 set;
@@ -803,7 +803,7 @@ int w83977af_dma_receive(struct w83977af_ir *self)
  *    Finished with receiving a frame
  *
  */
-int w83977af_dma_receive_complete(struct w83977af_ir *self)
+static int w83977af_dma_receive_complete(struct w83977af_ir *self)
 {
 	struct sk_buff *skb;
 	struct st_fifo *st_fifo;

