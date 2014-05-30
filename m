From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: [PATCH 0/8] ethernet: marvell: After-TSO fixes
Date: Fri, 30 May 2014 13:40:03 -0300
Message-ID: <1401468011-10609-1-git-send-email-ezequiel.garcia@free-electrons.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	Tawfik Bayouk <tawfik@marvell.com>, fugang.duan@freescale.com,
	Willy Tarreau <w@1wt.eu>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:58402 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751776AbaE3QlD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 12:41:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset consists of different fixes and improvements in the mvneta
and mv643xx_eth drivers. The most important change is the one that allows
to support small MSS values (see patches 2 and 6).

This is done following the Solarflare driver (see commit 7e6d06f0de3f7).

While doing this some other fixes were spotted and so they are included.

Finally, notice that the TSO support introduced a wrong DMA unmapping
of the TSO header buffers, so patches 4 and 8 provide a couple patches to
fix that in the drivers.

Ezequiel Garcia (8):
  net: mvneta: Use default NAPI weight instead of a custom one
  net: mvneta: Limit the TSO segments and adjust stop/wake thresholds
  net: mvneta: Fix missing DMA region unmap
  net: mvneta: Avoid unmapping the TSO header buffers
  net: mv643xx_eth: Count dropped packets properly
  net: mv643xx_eth: Limit the TSO segments and adjust stop/wake
    thresholds
  net: mv643xx_eth: Drop the NETDEV_TX_BUSY return path
  net: mv643xx_eth: Avoid unmapping the TSO header buffers

 drivers/net/ethernet/marvell/mv643xx_eth.c | 76 ++++++++++++++++++++----------
 drivers/net/ethernet/marvell/mvneta.c      | 46 +++++++++++++-----
 2 files changed, 85 insertions(+), 37 deletions(-)

-- 
1.9.1
