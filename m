From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: [PATCH v3 0/8] net: ethernet: marvell: Assorted fixes
Date: Thu, 22 May 2014 20:06:55 -0300
Message-ID: <1400800023-1562-1-git-send-email-ezequiel.garcia@free-electrons.com>
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	Tawfik Bayouk <tawfik@marvell.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:49686 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753108AbaEVXHv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2014 19:07:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

New round for this assorted fixes and clean-up series. There is more room for
clean-ups, and I'll start preparing more patches once these are accepted.

This series consists of cleanups and minor improvements on mvneta, mv643xx_eth
and mvmdio drivers. None of the patches imply any functionality change, except
for the patch six "Change the number of default rx queues to one".

This patch reduces the driver's allocated resources and makes the multiqueue
path in the poll function not get taken. The previous patchset contains more
details:

  http://permalink.gmane.org/gmane.linux.network/315015

As usual, any feedback on this will be well received!

Changes from v2:

  * Rebased on today's net-next and dropped patch 
    "net: mvneta: Factorize feature setting", merged in the recent
    TSO series.

  * As per Sergei suggestion, used devm_kcalloc or devm_kmalloc_array
    when suitable.

Changes from v1:

  * Added two more clean-up patches to the series.

  * Added Sebastian's Acked-by's.

  * Fixed extra empty line in "net: mv643xx_eth: Simplify
    mv643xx_eth_adjust_link()" as pointed out by David Miller.

Ezequiel Garcia (8):
  net: mv643xx_eth: Simplify mv643xx_eth_adjust_link()
  net: mvneta: Clean-up mvneta_tx_frag_process()
  net: mvneta: Check tx queue setup error in mvneta_change_mtu()
  net: mvneta: Clean-up mvneta_init()
  net: mvneta: Use prepare/commit API to simplify MAC address setting
  net: mvneta: Change the number of default rx queues to one
  net: mvmdio: Use devm_* API to simplify the code
  net: mvneta: Remove unneeded 'weigth' field

 drivers/net/ethernet/marvell/mv643xx_eth.c | 14 ++---
 drivers/net/ethernet/marvell/mvmdio.c      | 18 ++----
 drivers/net/ethernet/marvell/mvneta.c      | 91 ++++++++++++------------------
 3 files changed, 45 insertions(+), 78 deletions(-)

-- 
1.9.1
