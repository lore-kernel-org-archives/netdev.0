From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: [PATCH 1/2] pcmcia: remove unused IRQ_FIRST_SHARED
Date: Mon, 14 Dec 2009 19:57:38 +0100
Message-ID: <1260817059-24982-1-git-send-email-linux@dominikbrodowski.net>
References: <20091214185530.GA24593@comet.dominikbrodowski.net>
Cc: Dominik Brodowski <linux@dominikbrodowski.net>,
	Karsten Keil <keil@b1-systems.de>, netdev@vger.kernel.org,
	alsa-devel@alsa-project.org, Komuro <komurojun-mbn@nifty.com>
To: <linux-pcmcia@lists.infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isilmar.linta.de ([213.133.102.198]:42531 "EHLO linta.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756960AbZLNTAA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Dec 2009 14:00:00 -0500
In-Reply-To: <20091214185530.GA24593@comet.dominikbrodowski.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Komuro pointed out that IRQ_FIRST_SHARED is not used at all in the
PCMCIA subsystem, so remove it. Also, remove two bogus assignments.

CC: Karsten Keil <keil@b1-systems.de>
CC: netdev@vger.kernel.org
CC: alsa-devel@alsa-project.org
CC: Komuro <komurojun-mbn@nifty.com>
Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>
---
 drivers/isdn/hardware/avm/avm_cs.c |    3 +--
 drivers/isdn/hisax/avma1_cs.c      |    3 +--
 drivers/isdn/hisax/elsa_cs.c       |    2 +-
 drivers/isdn/hisax/sedlbauer_cs.c  |    2 +-
 drivers/isdn/hisax/teles_cs.c      |    2 +-
 drivers/net/pcmcia/axnet_cs.c      |    2 +-
 drivers/net/pcmcia/fmvj18x_cs.c    |    2 +-
 drivers/net/pcmcia/pcnet_cs.c      |    2 +-
 drivers/net/pcmcia/smc91c92_cs.c   |    2 +-
 drivers/net/pcmcia/xirc2ps_cs.c    |    2 +-
 include/pcmcia/cs.h                |    4 ++--
 sound/pcmcia/pdaudiocf/pdaudiocf.c |    3 ++-
 12 files changed, 14 insertions(+), 15 deletions(-)

diff --git a/drivers/isdn/hardware/avm/avm_cs.c b/drivers/isdn/hardware/avm/avm_cs.c
index 5a6ae64..94b796d 100644
--- a/drivers/isdn/hardware/avm/avm_cs.c
+++ b/drivers/isdn/hardware/avm/avm_cs.c
@@ -108,8 +108,7 @@ static int avmcs_probe(struct pcmcia_device *p_dev)
     p_dev->io.NumPorts2 = 0;
 
     /* Interrupt setup */
-    p_dev->irq.Attributes = IRQ_TYPE_EXCLUSIVE;
-    p_dev->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING|IRQ_FIRST_SHARED;
+    p_dev->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
 
     /* General socket configuration */
     p_dev->conf.Attributes = CONF_ENABLE_IRQ;
diff --git a/drivers/isdn/hisax/avma1_cs.c b/drivers/isdn/hisax/avma1_cs.c
index f9bdff3..e5deb15 100644
--- a/drivers/isdn/hisax/avma1_cs.c
+++ b/drivers/isdn/hisax/avma1_cs.c
@@ -120,8 +120,7 @@ static int avma1cs_probe(struct pcmcia_device *p_dev)
     p_dev->io.IOAddrLines = 5;
 
     /* Interrupt setup */
-    p_dev->irq.Attributes = IRQ_TYPE_EXCLUSIVE;
-    p_dev->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING|IRQ_FIRST_SHARED;
+    p_dev->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
 
     /* General socket configuration */
     p_dev->conf.Attributes = CONF_ENABLE_IRQ;
diff --git a/drivers/isdn/hisax/elsa_cs.c b/drivers/isdn/hisax/elsa_cs.c
index a2f709f..c9a30b1 100644
--- a/drivers/isdn/hisax/elsa_cs.c
+++ b/drivers/isdn/hisax/elsa_cs.c
@@ -137,7 +137,7 @@ static int elsa_cs_probe(struct pcmcia_device *link)
     local->cardnr = -1;
 
     /* Interrupt setup */
-    link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING|IRQ_FIRST_SHARED;
+    link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
     link->irq.Handler = NULL;
 
     /*
diff --git a/drivers/isdn/hisax/sedlbauer_cs.c b/drivers/isdn/hisax/sedlbauer_cs.c
index af5d393..7836ec3 100644
--- a/drivers/isdn/hisax/sedlbauer_cs.c
+++ b/drivers/isdn/hisax/sedlbauer_cs.c
@@ -144,7 +144,7 @@ static int sedlbauer_probe(struct pcmcia_device *link)
     link->priv = local;
 
     /* Interrupt setup */
-    link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING|IRQ_FIRST_SHARED;
+    link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
     link->irq.Handler = NULL;
 
     /*
diff --git a/drivers/isdn/hisax/teles_cs.c b/drivers/isdn/hisax/teles_cs.c
index ea70539..b0c5976 100644
--- a/drivers/isdn/hisax/teles_cs.c
+++ b/drivers/isdn/hisax/teles_cs.c
@@ -127,7 +127,7 @@ static int teles_probe(struct pcmcia_device *link)
     link->priv = local;
 
     /* Interrupt setup */
-    link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING|IRQ_FIRST_SHARED;
+    link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING;
     link->irq.Handler = NULL;
 
     /*
diff --git a/drivers/net/pcmcia/axnet_cs.c b/drivers/net/pcmcia/axnet_cs.c
index 800597b..cb2ce03 100644
--- a/drivers/net/pcmcia/axnet_cs.c
+++ b/drivers/net/pcmcia/axnet_cs.c
@@ -270,7 +270,7 @@ static int try_io_port(struct pcmcia_device *link)
 	    /* for master/slave multifunction cards */
 	    link->io.Attributes2 = IO_DATA_PATH_WIDTH_8;
 	    link->irq.Attributes =
-		IRQ_TYPE_DYNAMIC_SHARING|IRQ_FIRST_SHARED;
+		IRQ_TYPE_DYNAMIC_SHARING;
 	}
     } else {
 	/* This should be two 16-port windows */
diff --git a/drivers/net/pcmcia/fmvj18x_cs.c b/drivers/net/pcmcia/fmvj18x_cs.c
index 6e3e1ce..fc5a890 100644
--- a/drivers/net/pcmcia/fmvj18x_cs.c
+++ b/drivers/net/pcmcia/fmvj18x_cs.c
@@ -426,7 +426,7 @@ static int fmvj18x_config(struct pcmcia_device *link)
 
     if (link->io.NumPorts2 != 0) {
     	link->irq.Attributes =
-		IRQ_TYPE_DYNAMIC_SHARING|IRQ_FIRST_SHARED;
+		IRQ_TYPE_DYNAMIC_SHARING;
 	ret = mfc_try_io_port(link);
 	if (ret != 0) goto failed;
     } else if (cardtype == UNGERMANN) {
diff --git a/drivers/net/pcmcia/pcnet_cs.c b/drivers/net/pcmcia/pcnet_cs.c
index cbe462e..f41fbcc 100644
--- a/drivers/net/pcmcia/pcnet_cs.c
+++ b/drivers/net/pcmcia/pcnet_cs.c
@@ -490,7 +490,7 @@ static int try_io_port(struct pcmcia_device *link)
 	    /* for master/slave multifunction cards */
 	    link->io.Attributes2 = IO_DATA_PATH_WIDTH_8;
 	    link->irq.Attributes =
-		IRQ_TYPE_DYNAMIC_SHARING|IRQ_FIRST_SHARED;
+		IRQ_TYPE_DYNAMIC_SHARING;
 	}
     } else {
 	/* This should be two 16-port windows */
diff --git a/drivers/net/pcmcia/smc91c92_cs.c b/drivers/net/pcmcia/smc91c92_cs.c
index 9e0da37..49185c3 100644
--- a/drivers/net/pcmcia/smc91c92_cs.c
+++ b/drivers/net/pcmcia/smc91c92_cs.c
@@ -454,7 +454,7 @@ static int mhz_mfc_config(struct pcmcia_device *link)
     link->conf.Attributes |= CONF_ENABLE_SPKR;
     link->conf.Status = CCSR_AUDIO_ENA;
     link->irq.Attributes =
-	IRQ_TYPE_DYNAMIC_SHARING|IRQ_FIRST_SHARED;
+	IRQ_TYPE_DYNAMIC_SHARING;
     link->io.IOAddrLines = 16;
     link->io.Attributes2 = IO_DATA_PATH_WIDTH_8;
     link->io.NumPorts2 = 8;
diff --git a/drivers/net/pcmcia/xirc2ps_cs.c b/drivers/net/pcmcia/xirc2ps_cs.c
index fe504b7..55fa5ca 100644
--- a/drivers/net/pcmcia/xirc2ps_cs.c
+++ b/drivers/net/pcmcia/xirc2ps_cs.c
@@ -841,7 +841,7 @@ xirc2ps_config(struct pcmcia_device * link)
 	    link->conf.Attributes |= CONF_ENABLE_SPKR;
 	    link->conf.Status |= CCSR_AUDIO_ENA;
 	}
-	link->irq.Attributes |= IRQ_TYPE_DYNAMIC_SHARING|IRQ_FIRST_SHARED ;
+	link->irq.Attributes |= IRQ_TYPE_DYNAMIC_SHARING;
 	link->io.NumPorts2 = 8;
 	link->io.Attributes2 = IO_DATA_PATH_WIDTH_8;
 	if (local->dingo) {
diff --git a/include/pcmcia/cs.h b/include/pcmcia/cs.h
index afc2bfb..75fa353 100644
--- a/include/pcmcia/cs.h
+++ b/include/pcmcia/cs.h
@@ -126,8 +126,8 @@ typedef struct irq_req_t {
 #define IRQ_TYPE_TIME			0x01
 #define IRQ_TYPE_DYNAMIC_SHARING	0x02
 #define IRQ_FORCED_PULSE		0x04
-#define IRQ_FIRST_SHARED		0x08
-//#define IRQ_HANDLE_PRESENT		0x10
+#define IRQ_FIRST_SHARED		0x08 /* unused */
+#define IRQ_HANDLE_PRESENT		0x10 /* unused */
 #define IRQ_PULSE_ALLOCATED		0x100
 
 /* Bits in IRQInfo1 field */
diff --git a/sound/pcmcia/pdaudiocf/pdaudiocf.c b/sound/pcmcia/pdaudiocf/pdaudiocf.c
index 7717e01..edaa729 100644
--- a/sound/pcmcia/pdaudiocf/pdaudiocf.c
+++ b/sound/pcmcia/pdaudiocf/pdaudiocf.c
@@ -143,7 +143,8 @@ static int snd_pdacf_probe(struct pcmcia_device *link)
 	link->io.NumPorts1 = 16;
 
 	link->irq.Attributes = IRQ_TYPE_EXCLUSIVE | IRQ_FORCED_PULSE;
-	// link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING|IRQ_FIRST_SHARED;
+	/* FIXME: This driver should be updated to allow for dynamic IRQ sharing */
+	/* link->irq.Attributes = IRQ_TYPE_DYNAMIC_SHARING | IRQ_FORCED_PULSE; */
 
 	link->irq.Handler = pdacf_interrupt;
 	link->conf.Attributes = CONF_ENABLE_IRQ;
-- 
1.6.3.3

