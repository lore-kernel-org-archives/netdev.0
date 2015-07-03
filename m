From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: [PATCH 0/6] net: mvneta: Switch to per-CPU irq and make rxq_def useful
Date: Fri,  3 Jul 2015 16:25:45 +0200
Message-ID: <1435933551-28696-1-git-send-email-maxime.ripard@free-electrons.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Maxime Ripard <maxime.ripard@free-electrons.com>
To: Thomas Gleixner <tglx@linutronix.de>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from down.free-electrons.com ([37.187.137.238]:37799 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755708AbbGCObH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jul 2015 10:31:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patchset reworks the Marvell neta driver in order to really
support its per-CPU interrupts, instead of faking them as SPI, and
allow the use of any RX queue instead of the hardcoded RX queue 0 that
we have currently.

Let me know what you think,
Maxime

Maxime Ripard (6):
  net: mvneta: Fix CPU_MAP registers initialisation
  genirq: Fix the documentation of request_percpu_irq
  irqchip: armada-370-xp: Rework per-cpu interrupts handling
  net: mvneta: Handle per-cpu interrupts
  net: mvneta: Allow different queues
  net: mvneta: Statically assign queues to CPUs

 drivers/irqchip/irq-armada-370-xp.c   |  14 +--
 drivers/net/ethernet/marvell/mvneta.c | 187 ++++++++++++++++------------------
 kernel/irq/manage.c                   |   7 +-
 3 files changed, 98 insertions(+), 110 deletions(-)

-- 
2.4.5
