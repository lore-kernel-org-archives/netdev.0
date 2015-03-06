From: Boris Brezillon <boris.brezillon@free-electrons.com>
Subject: [PATCH v3 0/2] net/macb: merge at91_ether driver into macb driver
Date: Fri,  6 Mar 2015 11:48:39 +0100
Message-ID: <1425638921-9768-1-git-send-email-boris.brezillon@free-electrons.com>
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>,
	Jean-Christophe Plagniol-Villard <plagnioj@jcrosoft.com>,
	Alexandre Belloni <alexandre.belloni@free-electrons.com>,
	Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>, devicetree@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Boris Brezillon <boris.brezillon@free-electrons.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from down.free-electrons.com ([37.187.137.238]:36508 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932307AbbCFKsq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2015 05:48:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

The rm9200 boards use the dedicated at91_ether driver instead of the
regular macb driver.

Both the macb and at91_ether drivers can be compiled as separated
modules.
Since the at91_ether driver uses code from the macb driver, at91_ether.ko
depends on macb.ko.

However the macb.ko module always fails to load on rm9200 boards: the
macb_probe() function expects a hclk clock which doesn't exist on rm9200.
Then the at91_ether.ko can't be loaded in turn due to unresolved
dependencies.

This series of patches fix this issue by merging at91_ether into macb.

This series depends on this one [1].

Best Regards,

Boris

Changes since v2:
- rebase after changed brought by [1]

Changes since v1:
- rework probe functions to share common probing logic

[1]https://lkml.org/lkml/2015/3/6/234

Cyrille Pitchen (2):
  net/macb: unify clock management
  net/macb: merge at91_ether driver into macb driver

 drivers/net/ethernet/cadence/Kconfig      |   8 -
 drivers/net/ethernet/cadence/Makefile     |   1 -
 drivers/net/ethernet/cadence/at91_ether.c | 481 ----------------------
 drivers/net/ethernet/cadence/macb.c       | 660 ++++++++++++++++++++++--------
 drivers/net/ethernet/cadence/macb.h       |  10 +-
 5 files changed, 493 insertions(+), 667 deletions(-)
 delete mode 100644 drivers/net/ethernet/cadence/at91_ether.c

-- 
1.9.1
