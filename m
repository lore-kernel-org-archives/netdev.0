From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [PATCH 0/3] Intel IXP4xx network drivers
Date: Mon, 07 May 2007 01:46:39 +0200
Message-ID: <m3abwhcy74.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.arm.linux.org.uk
To: Jeff Garzik <jeff@garzik.org>, Russell King <rmk@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:38094 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752338AbXEFXql (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 May 2007 19:46:41 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

The next 3 patches:
[1/3] changes "depends on HDLC" to "select HDLC" for WAN/generic HDLC
      network drivers
[2/3] adds "fuse" functions to help determine installed IXP4xx CPU
      components and to reset/disable/enable them.
[3/3] adds IXP4xx drivers for: hardware queue manager, NPE (on-chip
      network coprocessors), built-in Ethernet ports, built-in HSS
      (sync serial) ports (currently only non-channelized HDLC).

Patch [3/3] requires patches [1/3] and [2/3]

The code is based on publicly available information:
- Intel IXP4xx Developer's Manual and others e-papers
- Intel IXP400 Access Library Software (BSD license)
- previous works by Christian Hohnstaedt <chohnstaedt@innominate.com>
  While I have decided to rewrite most things from scratch, his patch
  was a great help in understanding what's going on within the IXP400
  code (I took some fragments of his code as well).
  Thanks, Christian.

The code is tested with IXP425 CPU.

[1/3]
 drivers/net/wan/Kconfig                   |   31 +-

[2/3]
 include/asm-arm/arch-ixp4xx/ixp4xx-regs.h |   47 ++

[3/3]
 arch/arm/mach-ixp4xx/ixdp425-setup.c      |   27 +
 drivers/net/Kconfig                       |   34 +
 drivers/net/Makefile                      |    1 
 drivers/net/ixp4xx/Makefile               |    4 
 drivers/net/ixp4xx/ixp4xx_eth.c           | 1002 +++++++++++++++++++++++++++
 drivers/net/ixp4xx/ixp4xx_hss.c           | 1048 ++++++++++++++++++++++++++++
 drivers/net/ixp4xx/ixp4xx_npe.c           |  731 +++++++++++++++++++++
 drivers/net/ixp4xx/ixp4xx_qmgr.c          |  273 +++++++
 drivers/net/ixp4xx/npe.h                  |   41 +
 drivers/net/ixp4xx/qmgr.h                 |  124 +++
 drivers/net/wan/Kconfig                   |   10 
 include/asm-arm/arch-ixp4xx/platform.h    |   19 
-- 
Krzysztof Halasa
