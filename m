From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: [PATCH] mvneta: DMA API misusage fix
Date: Thu,  5 Dec 2013 13:35:36 -0300
Message-ID: <1386261337-26442-1-git-send-email-ezequiel.garcia@free-electrons.com>
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>, Willy Tarreau <w@1wt.eu>,
	Jason Cooper <jason@lakedaemon.net>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	"David S. Miller" <davem@davemloft.net>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:47750 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932576Ab3LEQfs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 11:35:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This small patch removes a DMA_API_DEBUG warning, fixing a DMA API misusage.
The change is straightforward: rx DMA mappings are created setting a size
(using some upper-limit buffer size), but destroyed (aka unmapped) setting
the actual data size that was received.

The fix replaces 'data_size' by the MVNETA_RX_BUF_SIZE in the unmap.

I'm not sure how serious this misusage is, so I'd like to ask for advise
about marking this commit for stable. The problem is here since the
introduction of the driver, namely since:

  commit c5aff18204da025fdf714f8f6423372b4b8efd00
  net: mvneta: driver for Marvell Armada 370/XP network unit

Thanks!

Ezequiel Garcia (1):
  net: mvneta: Fix incorrect DMA unmapping size

 drivers/net/ethernet/marvell/mvneta.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

-- 
1.8.1.5
