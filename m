From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: [PATCH 0/1] mv643xx_eth: Disable TSO by default
Date: Sat,  1 Nov 2014 12:30:19 -0300
Message-ID: <1414855820-15094-1-git-send-email-ezequiel.garcia@free-electrons.com>
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Tawfik Bayouk <tawfik@marvell.com>,
	Lior Amsalem <alior@marvell.com>,
	Nadav Haklai <nadavh@marvell.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from down.free-electrons.com ([37.187.137.238]:46883 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751626AbaKAPcC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Nov 2014 11:32:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Several users ([1], [2]) have been reporting data corruption with TSO on
Kirkwood platforms (i.e. using the mv643xx_eth driver).

Until we manage to find what's causing this, this simple patch will make
the TSO path disabled by default. This patch should be queued for stable,
fixing the TSO feature introduced in v3.16.

The corruption itself is very easy to reproduce: checking md5sum on a mounted
NFS directory gives a different result each time. Same tests using the mvneta
driver (Armada 370/38x/XP SoC) pass with no issues.

Frankly, I'm a bit puzzled about this, and so any ideas or debugging hints
are well received.

[1] https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=764162
[2] http://archlinuxarm.org/forum/viewtopic.php?f=9&t=7692

Ezequiel Garcia (1):
  net: mv643xx_eth: Make TSO disabled by default

 drivers/net/ethernet/marvell/mv643xx_eth.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

-- 
2.1.0
