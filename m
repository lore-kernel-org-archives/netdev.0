From: Arjan van de Ven <arjan@infradead.org>
Subject: [PATCH] ide/net: flip the order of SATA and network init
Date: Tue, 27 Jan 2009 14:19:52 -0800
Message-ID: <20090127141952.51785b4f@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
To: linux-ide@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:49185 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752524AbZA0WTv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 17:19:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From e89d6840ad685a3c61f72367d4ac5bfed69ead0c Mon Sep 17 00:00:00 2001
From: Arjan van de Ven <arjan@linux.intel.com>
Date: Mon, 26 Jan 2009 18:58:11 -0800
Subject: [PATCH] ide/net: flip the order of SATA and network init

this patch flips the order in which sata and network drivers are initialized.

SATA probing takes quite a bit of time, and with the asynchronous infrastructure
other drivers that run after it can execute in parallel. Network drivers do tend
to take some real time talking to the hardware, so running these later is
a good thing (the sata probe then runs concurrent)

This saves about 15% of my kernels boot time.

Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>
---
 drivers/Makefile |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/Makefile b/drivers/Makefile
index c1bf417..2618a61 100644
--- a/drivers/Makefile
+++ b/drivers/Makefile
@@ -36,13 +36,14 @@ obj-$(CONFIG_FB_INTEL)          += video/intelfb/
 
 obj-y				+= serial/
 obj-$(CONFIG_PARPORT)		+= parport/
-obj-y				+= base/ block/ misc/ mfd/ net/ media/
+obj-y				+= base/ block/ misc/ mfd/ media/
 obj-$(CONFIG_NUBUS)		+= nubus/
-obj-$(CONFIG_ATM)		+= atm/
 obj-y				+= macintosh/
 obj-$(CONFIG_IDE)		+= ide/
 obj-$(CONFIG_SCSI)		+= scsi/
 obj-$(CONFIG_ATA)		+= ata/
+obj-y				+= net/
+obj-$(CONFIG_ATM)		+= atm/
 obj-$(CONFIG_FUSION)		+= message/
 obj-$(CONFIG_FIREWIRE)		+= firewire/
 obj-y				+= ieee1394/
-- 
1.6.0.5



-- 
Arjan van de Ven 	Intel Open Source Technology Centre
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org
