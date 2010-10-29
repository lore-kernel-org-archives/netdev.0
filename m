From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [RFC PATCH 0/2] SL351x (Gemini) ethernet driver
Date: Fri, 29 Oct 2010 12:23:06 +0200 (CEST)
Message-ID: <cover.1288321597.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Paulius Zaleckas <paulius.zaleckas@gmail.com>,
	Janos Laube <janos.dev@gmail.com>
To: Hans Ulli Kroll <ulli.kroll@googlemail.com>,
	Russell King <linux@arm.linux.org.uk>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:44357 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752261Ab0J2KXJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Oct 2010 06:23:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a driver for SL351x (Gemini) SoC ethernet peripheral.
Based on work by Paulius Zaleckas and GPLd code from Raidsonic
and other NAS vendors.

This is work in progress. Please comment and test if you can.
Patches are against 2.6.37-rc (current Linus' tree) but should
apply to 2.6.36. You probably also need patches for PATA from
	git://git.berlios.de/gemini-board ib4220

Known bugs:
 - repeatable bad HW calculated TCP csum
    happens for only some packets in a TCP stream
    looks like it doesn't like some data pattern or timing
    (difference between correct and generated csum is the same
    when the packet is retransmitted with changed header/TCP tstamp)
 - TX DMA hangs sometimes (needs module reload when that happens)
    with debugging printks disabled and HW TX csum enabled
 - unsynced counters

I started to work on Paulius' code to find out why the TX DMA hangs
happen, but then I realized that complete rewrite was a better way
to understand how the hardware works and why it doesn't. As a "bonus"
this got some additional features:
 - ethtool support
 - 64-bit counters
 - proper cleanup on ifdown/module unload
 - better DMA API usage
 - cleaned up code
 - a lot of tx/rx debugging printks
 - based on 2.6.36 DMA and netdev interfaces

TODO:
 - NAPI
 - MTU changing

=46or normal use tx-csum and tso have to be disabled:
   ethtool -K eth0 tso off tx off

Tested on Raidsonic IcyBox 4220-B (dual SATA NAS).

I'm also interested in getting copies of various GPL packages for
StorLink SL3516. I already have following packages (md5sum):

89991e543eb2e473e3d380ac9a4cd8b4  GPL_source_code(Raidsonic).zip
6ba8b833c429794315f0a73ce2961bd8  Gemini_v2_6_0-n.tgz
fe87e97a33554bcab8284d25ff86e383  n299_n199_1.00.24_GPL.tar.bz2
eca8994354368304ca3b5bd1429c20bb  sl-boot_1.0.9.tgz
eafd6497074fe0651459bf38c39d66bd  vt4kern-1.5.tar.bz2.tar


Best Regards,
Micha=C5=82 Miros=C5=82aw

---

Micha=C5=82 Miros=C5=82aw (2):
  Gemini: create platform device for ethernet in Raidsonic IB-4220B
  Gemini: SL351x Ethernet driver

 arch/arm/mach-gemini/board-nas4220b.c    |   53 +
 arch/arm/mach-gemini/common.h            |    2 +
 arch/arm/mach-gemini/devices.c           |   52 +
 arch/arm/mach-gemini/include/mach/gmac.h |   21 +
 drivers/net/Kconfig                      |    7 +
 drivers/net/Makefile                     |    1 +
 drivers/net/sl351x.c                     | 1706 ++++++++++++++++++++++=
++++++++
 drivers/net/sl351x_hw.h                  | 1423 ++++++++++++++++++++++=
+++
 8 files changed, 3265 insertions(+), 0 deletions(-)
 create mode 100644 arch/arm/mach-gemini/include/mach/gmac.h
 create mode 100644 drivers/net/sl351x.c
 create mode 100644 drivers/net/sl351x_hw.h

