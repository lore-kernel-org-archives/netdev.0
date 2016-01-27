From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 0/9] network driver fixes
Date: Wed, 27 Jan 2016 15:04:50 +0100
Message-ID: <1453903507-3427225-1-git-send-email-arnd@arndb.de>
Cc: linux-arm-kernel@lists.infradead.org,
	Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.133]:52739 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754261AbcA0OFw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2016 09:05:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These are all fixes for relatively harmless bugs that showed up
in my randconfig testing, so they should not be needed for v4.5
but get merged into net-next.

I've managed to address all 'uninitialized variable' warnings that
I get in ARM randconfig kernels now, this series includes the
last five I got in network drivers. They are often really annoying
warnings but when we get new ones, they often are about actual
bugs in corner cases, so I'm trying hard to eliminate the false
positives here to get people to pay attention to added warnings.
I've recently tried building with an older gcc and found tons more
that are all bogus, this series only addresses the ones that
gcc-5.2 finds.

Arnd Bergmann (9):
  net: davinci_cpdma: use dma_addr_t for DMA address
  net: hp100: remove unnecessary #ifdefs
  net: bgmac: clarify CONFIG_BCMA dependency
  net: moxart: use correct accessors for DMA memory
  net: fddi/defxx: avoid warning about uninitialized variable use
  net: vxge: avoid unused function warnings
  net: macb: avoid uninitialized variables
  net: nb8800: avoid uninitialized variable warning
  net: tg3: avoid uninitialized variable warning

 drivers/net/ethernet/aurora/nb8800.c           |  4 +--
 drivers/net/ethernet/broadcom/Kconfig          |  5 ++-
 drivers/net/ethernet/broadcom/tg3.c            |  2 +-
 drivers/net/ethernet/cadence/macb.c            |  1 +
 drivers/net/ethernet/hp/hp100.c                | 18 -----------
 drivers/net/ethernet/moxa/moxart_ether.c       | 42 ++++++++++++++++----------
 drivers/net/ethernet/moxa/moxart_ether.h       |  4 +--
 drivers/net/ethernet/neterion/vxge/vxge-main.c | 31 ++++++++-----------
 drivers/net/ethernet/ti/davinci_cpdma.c        | 12 ++++----
 drivers/net/fddi/defxx.c                       |  5 +++
 10 files changed, 59 insertions(+), 65 deletions(-)

-- 
2.7.0
