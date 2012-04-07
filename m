From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Pull request for 'davem-next.base_addr.removal' branch
Date: Sat, 7 Apr 2012 12:20:51 +0200
Message-ID: <20120407102051.GA5551@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Andrew Gallatin <gallatin@myri.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Chris Snook <chris.snook@gmail.com>,
	Daniele Venzano <venza@brownhat.org>,
	David Lv <DavidLv@viatech.com.cn>,
	Grant Grundler <grantgrundler@gmail.com>,
	Ion Badulescu <ionut@badula.org>,
	Jay Cliburn <jcliburn@gmail.com>, Jon Mason <jdmason@kudzu.us>,
	Jon Mason <mason@myri.com>, Michael Chan <mchan@broadcom.com>,
	Stanislav Yakovlev <stas.yakovlev@gmail.com>,
	Steve Glendinning <steve.glendinning@smsc.com>,
	Tim Hockin <thockin@hockin.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:45273 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752789Ab2DGKYw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 Apr 2012 06:24:52 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please pull from branch 'davem-next.base_addr.removal' in repository

git://violet.fr.zoreil.com/romieu/linux davem-next.base_addr.removal

to get the changes below.

Changes since #2 (2012/04/06)
- reverted the request_irq tests for '< 0' to their original state
  (see patch below)
- added Acked-by from Michael Chan, Grant Grundler, Andrew Gallatin

Changes since #1 (2012/03/15)

- display the PCI resource address in the bnx2 driver as suggested by
  Michael Chan. It is done as well where things have been moved to mapped
  addresses, namely sc92031, epic100 and rrunner. I have not done it where
  net_device.base_addr already contained a mapped address.

- convert drivers to io{read/write} in place of inl/out #define. Minimal
  comments keep trace of the nature of the committed PCI bar range when it
  gets remapped. It applies to dl2k, dmfe, epic100, uli526x, xircom_cb

- reworked the chip dependent uli526x phy operations to minimize conditional
  registers offsets and parameters. void (__iomem) * are too easy to abuse.

- added myri10ge, rrunner, ipw2100, ipw2200

Few files changed: a diff from the version #2 is included below.
Previous branch has been moved to davem-next.base_addr.removal-20120406.

I should be able to address Grant's suggestions for further changes this
week end after some r8169 work.

Distance from 'davem-next' (36b7777590be33567be50db7f82282c3237428ad)
---------------------------------------------------------------------

019d077a530d2c6d6032ddd92a91520c3479ff05
9b717075e96daed94a10b4b0aaeb88c4c4bb0da3
a3442794c5b7925ef240e8f5ce7683345f5cc84d
0193fc5efd95c18bed1d03c57b2f916906662753
a74254588754bf7bc5c60f2bcc9ee5f66b749ea2
57d6d456cfb89264f87d24f52640ede23fdf12bd
5820e97a299e502e71dd5587ed2bf63a75d4f4f7
aae9bc302de493ad62102e7cdb1e123648057b66
3acf4b5cde8123a7a243d9dcd63f3e6990c8e5bb
5e3cc4e3aaeae953c224bbe92f0ea8d90dfb1b63
65712ec016788538d27c0b0452e57b751776914e
d710ce135731c101b6fc131c07f3db0cdb0d95fd
b5a80837b7e125729a49b2a8b80558d09bea7e19
308f2888a3ff442167e2aea419225445b7a1b8b6
ebaf7f8f78e8600b56010121766ed832f2f57b0f
d59a1881c0ff63f9edbc7f4ad5a5e593fe779e1b
5e58deb917bfa8dad71cb2e2b9f9572746ff8e6a
7deb1182175ee06cfcea40452d4f2fb1e33fcbb8
a173460a6391ed5c38b63bcaedc6afc30f4de3b2
480c28642d794589b1279c06b9ef60f4a63acb59
c4a9f0854bbea281f3d332c8c2b2b65a67b11616
c0bd55efd7b7ea8346ec3b5ce8414f978fede1f5
c0357e975afdbbedab5c662d19bef865f02adc17
2d5fb6283cb921a1f66454f8a603aaa973cbc24b
ea8f2ed0f1b943e499e760feced4038f95b2b71f
0c18acc1ed57d54195427d16316d5ea09d840b0e
a69afe3263717ba9384cf18d05722c598f6820af
80777c54d2a6ebeff783b638e92fba40f0881ba5
b5efab99ed92dd3b432e2f414d3979e8c2acd382
436dfc461b87b49d67867a798c91cd8cfff23f12
32e819e46e028ec5901048baee66775d71c4ec51
c514f285c37fc705e59956ae0b9fc79d28905d3b
dfda3578867bbfa35c629b58b5886dd9f5da11ca
0ca0aa08eb70dd23c1bc5d154c3d8ba157b712e9
05d334eca9994680a6cb8fba3f19955356ccf72a
93f7fab433606a0ee6153788213de2a822736322
03a2384e68f8cd464320c79c8c8c9f75f7172fa5
9195182d82890c270819880695f491fcb2ac4ca2
4ee39fd1a97115f537664cf18dc85bda916c24e5

Diffstat
--------

 drivers/net/ethernet/adaptec/starfire.c          |   54 +--
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c  |    5 +-
 drivers/net/ethernet/atheros/atl1e/atl1e_main.c  |   17 +-
 drivers/net/ethernet/broadcom/bnx2.c             |   41 +--
 drivers/net/ethernet/dec/tulip/de2104x.c         |   34 +-
 drivers/net/ethernet/dec/tulip/dmfe.c            |  295 ++++++++-------
 drivers/net/ethernet/dec/tulip/tulip_core.c      |   27 +-
 drivers/net/ethernet/dec/tulip/uli526x.c         |  443 +++++++++++-----------
 drivers/net/ethernet/dec/tulip/winbond-840.c     |   17 +-
 drivers/net/ethernet/dec/tulip/xircom_cb.c       |  280 ++++++++------
 drivers/net/ethernet/dlink/dl2k.c                |  416 ++++++++++----------
 drivers/net/ethernet/dlink/dl2k.h                |   19 +-
 drivers/net/ethernet/dlink/sundance.c            |   12 +-
 drivers/net/ethernet/fealnx.c                    |   15 +-
 drivers/net/ethernet/myricom/myri10ge/myri10ge.c |    7 +-
 drivers/net/ethernet/natsemi/natsemi.c           |   67 ++--
 drivers/net/ethernet/neterion/s2io.c             |   14 +-
 drivers/net/ethernet/neterion/vxge/vxge-main.c   |   18 +-
 drivers/net/ethernet/nvidia/forcedeth.c          |    5 -
 drivers/net/ethernet/packetengines/hamachi.c     |   11 +-
 drivers/net/ethernet/packetengines/yellowfin.c   |   32 +-
 drivers/net/ethernet/realtek/8139cp.c            |   21 +-
 drivers/net/ethernet/realtek/8139too.c           |  136 +++----
 drivers/net/ethernet/silan/sc92031.c             |   34 +--
 drivers/net/ethernet/sis/sis190.c                |   26 +-
 drivers/net/ethernet/sis/sis900.c                |  375 ++++++++++---------
 drivers/net/ethernet/smsc/epic100.c              |  403 ++++++++++----------
 drivers/net/ethernet/smsc/smsc9420.c             |   47 ++--
 drivers/net/ethernet/sun/sungem.c                |    2 -
 drivers/net/ethernet/sun/sunhme.c                |   18 +-
 drivers/net/ethernet/sun/sunhme.h                |    1 +
 drivers/net/ethernet/tehuti/tehuti.c             |    4 -
 drivers/net/ethernet/via/via-rhine.c             |   12 +-
 drivers/net/ethernet/via/via-velocity.c          |    9 +-
 drivers/net/hippi/rrunner.c                      |   82 ++---
 drivers/net/wireless/ipw2x00/ipw2100.c           |  131 +++----
 drivers/net/wireless/ipw2x00/ipw2100.h           |    1 +
 drivers/net/wireless/ipw2x00/ipw2200.c           |    4 -
 38 files changed, 1525 insertions(+), 1610 deletions(-)

Shortlog
--------

Francois Romieu (39):
      sungem: stop using net_device.{base_addr, irq}.
      tehuti: stop using net_device.{base_addr, irq}.
      forcedeth: stop using net_device.{base_addr, irq}.
      atl1c: stop using net_device.{base_addr, irq}.
      via-rhine: stop using net_device.{base_addr, irq}.
      hamachi: stop using net_device.{base_addr, irq}.
      via-velocity: stop using net_device.{base_addr, irq}.
      sundance: stop using net_device.{base_addr, irq}.
      vxge: stop using net_device.{base_addr, irq}.
      fealnx: stop using net_device.{base_addr, irq}.
      atl1e: stop using net_device.{base_addr, irq}.
      s2io: stop using net_device.{base_addr, irq}.
      8139cp: stop using net_device.{base_addr, irq}.
      yellowfin: stop using net_device.{base_addr, irq}.
      starfire: stop using net_device.{base_addr, irq}.
      starfire: remove deprecated options.
      bnx2: stop using net_device.{base_addr, irq}.
      winbond840: stop using net_device.{base_addr, irq}.
      sc92031: stop using net_device.{base_addr, irq}
      sis190: stop using net_device.{base_addr, irq}
      tulip_core: stop using net_device.{base_addr, irq}.
      sunhme: stop using net_device.{base_addr, irq}.
      uli526x: fix regions leak in driver probe error path.
      xircom_cb: fix device probe error path.
      xircom_cb: stop using net_device.{base_addr, irq} and convert to __iomem.
      de2104x: stop using net_device.{base_addr, irq}.
      smsc9420: stop using net_device.{base_addr, irq}.
      natsemi: stop using net_device.{base_addr, irq}.
      8139too: dev->{base_addr, irq} removal.
      dl2k: stop using net_device.{base_addr, irq} and convert to __iomem.
      uli526x: stop using net_device.{base_addr, irq} and convert to __iomem.
      epic100: stop using net_device.{base_addr, irq} and convert to __iomem.
      dmfe: stop using net_device.{base_addr, irq} and convert to __iomem.
      sis900: stop using net_device.{base_addr, irq} and convert to __iomem.
      myri10ge: stop using net_device.{base_addr, irq}.
      rrunner: stop using net_device.{base_addr, irq}.
      ipw2200: stop using net_device.{base_addr, irq}.
      ipw2100: stop using net_device.base_addr.
      ipw2100: remove useless tests in the PCI device remove path.

Patch from version #2
---------------------

diff --git a/drivers/net/ethernet/dec/tulip/tulip_core.c b/drivers/net/ethernet/dec/tulip/tulip_core.c
index 25fe117..c4f37ac 100644
--- a/drivers/net/ethernet/dec/tulip/tulip_core.c
+++ b/drivers/net/ethernet/dec/tulip/tulip_core.c
@@ -1902,7 +1902,7 @@ static int tulip_resume(struct pci_dev *pdev)
 
 	retval = request_irq(pdev->irq, tulip_interrupt, IRQF_SHARED,
 			     dev->name, dev);
-	if (retval < 0) {
+	if (retval) {
 		pr_err("request_irq failed in resume\n");
 		return retval;
 	}
diff --git a/drivers/net/ethernet/fealnx.c b/drivers/net/ethernet/fealnx.c
index 328c631..6f939a1 100644
--- a/drivers/net/ethernet/fealnx.c
+++ b/drivers/net/ethernet/fealnx.c
@@ -835,8 +835,8 @@ static int netdev_open(struct net_device *dev)
 	iowrite32(0x00000001, ioaddr + BCR);	/* Reset */
 
 	rc = request_irq(irq, intr_handler, IRQF_SHARED, dev->name, dev);
-	if (rc < 0)
-		goto out;
+	if (rc)
+		return -EAGAIN;
 
 	for (i = 0; i < 3; i++)
 		iowrite16(((unsigned short*)dev->dev_addr)[i],
diff --git a/drivers/net/ethernet/packetengines/yellowfin.c b/drivers/net/ethernet/packetengines/yellowfin.c
index cf5f54b..04e622f 100644
--- a/drivers/net/ethernet/packetengines/yellowfin.c
+++ b/drivers/net/ethernet/packetengines/yellowfin.c
@@ -574,8 +574,8 @@ static int yellowfin_open(struct net_device *dev)
 	iowrite32(0x80000000, ioaddr + DMACtrl);
 
 	rc = request_irq(irq, yellowfin_interrupt, IRQF_SHARED, dev->name, dev);
-	if (rc < 0)
-		goto out;
+	if (rc)
+		return rc;
 
 	rc = yellowfin_init_ring(dev);
 	if (rc < 0)
diff --git a/drivers/net/ethernet/smsc/epic100.c b/drivers/net/ethernet/smsc/epic100.c
index 1710b4b..d01e59c 100644
--- a/drivers/net/ethernet/smsc/epic100.c
+++ b/drivers/net/ethernet/smsc/epic100.c
@@ -657,7 +657,7 @@ static int epic_open(struct net_device *dev)
 
 	napi_enable(&ep->napi);
 	rc = request_irq(irq, epic_interrupt, IRQF_SHARED, dev->name, dev);
-	if (rc < 0) {
+	if (rc) {
 		napi_disable(&ep->napi);
 		return rc;
 	}
diff --git a/drivers/net/ethernet/smsc/smsc9420.c b/drivers/net/ethernet/smsc/smsc9420.c
index 292753f..fd33b21 100644
--- a/drivers/net/ethernet/smsc/smsc9420.c
+++ b/drivers/net/ethernet/smsc/smsc9420.c
@@ -1361,8 +1361,9 @@ static int smsc9420_open(struct net_device *dev)
 
 	result = request_irq(irq, smsc9420_isr, IRQF_SHARED | IRQF_DISABLED,
 			     DRV_NAME, pd);
-	if (result < 0) {
+	if (result) {
 		smsc_warn(IFUP, "Unable to use IRQ = %d", irq);
+		result = -ENODEV;
 		goto out_0;
 	}
 
diff --git a/drivers/net/ethernet/sun/sunhme.c b/drivers/net/ethernet/sun/sunhme.c
index a470f38..afb19a6 100644
--- a/drivers/net/ethernet/sun/sunhme.c
+++ b/drivers/net/ethernet/sun/sunhme.c
@@ -2185,12 +2185,12 @@ static int happy_meal_open(struct net_device *dev)
 	if ((hp->happy_flags & (HFLAG_QUATTRO|HFLAG_PCI)) != HFLAG_QUATTRO) {
 		res = request_irq(hp->irq, happy_meal_interrupt, IRQF_SHARED,
 				  dev->name, dev);
-		if (res < 0) {
+		if (res) {
 			HMD(("EAGAIN\n"));
 			printk(KERN_ERR "happy_meal(SBUS): Can't order irq %d to go.\n",
 			       hp->irq);
 
-			return res;
+			return -EAGAIN;
 		}
 	}
 
-- 
Ueimor

Will code drivers for food.
