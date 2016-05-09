From: John Crispin <john@phrozen.org>
Subject: [PATCH V2 00/22] net-next: mediatek: various fixes and IRQ grouping
Date: Mon,  9 May 2016 12:03:52 +0200
Message-ID: <1462788254-40572-1-git-send-email-john@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: nbd@nbd.name, netdev@vger.kernel.org,
	linux-mediatek@lists.infradead.org, John Crispin <john@phrozen.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:47262 "EHLO nbd.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751587AbcEIKEa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 May 2016 06:04:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series introduces a number of fixes that we stumbled across while
doing more performance testing and code level reviewing. Additionally
it improves the PHY setup code adding support for fixed phys, asymmetric
flow control and gigabit feature advertisement. Next the series adds a
support for IRQ grouping, allowing use to separate the IRQs onto more than
one core using irq affinity. The last two patches wrap up the series by
updating my email address.

John Crispin (22):
  net-next: mediatek: use mdiobus_free() in favour of kfree()
  net-next: mediatek: fix gigabit and flow control advertisement
  net-next: mediatek: add fixed-phy support
  net-next: mediatek: properly handle RGMII modes
  net-next: mediatek: fix DQL support
  net-next: mediatek: add missing return code check
  net-next: mediatek: fix missing free of scratch memory
  net-next: mediatek: invalid buffer lookup in mtk_tx_map()
  net-next: mediatek: dropped rx packets are not being counted properly
  net-next: mediatek: add next data pointer coherency protection
  net-next: mediatek: disable all interrupts during probe
  net-next: mediatek: fix threshold value
  net-next: mediatek: increase watchdog_timeo
  net-next: mediatek: fix off by one in the TX ring allocation
  net-next: mediatek: only wake the queue if it is stopped
  net-next: mediatek: remove superfluous queue wake up call
  net-next: mediatek: remove superfluous register reads
  net-next: mediatek: don't use intermediate variables to store IRQ
    masks
  net-next: mediatek: add IRQ locking
  net-next: mediatek: add support for IRQ grouping
  net-next: mediatek: change my email address
  MAINTAINERS: change my email address

 MAINTAINERS                                 |    2 +-
 drivers/net/ethernet/mediatek/mtk_eth_soc.c |  293 +++++++++++++++++----------
 drivers/net/ethernet/mediatek/mtk_eth_soc.h |   19 +-
 3 files changed, 209 insertions(+), 105 deletions(-)

-- 
1.7.10.4
