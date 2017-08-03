From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH net-next v2 0/7] net: mvpp2: add TX interrupts support
Date: Thu,  3 Aug 2017 10:41:54 +0200
Message-ID: <20170803084201.30305-1-thomas.petazzoni@free-electrons.com>
Cc: Nadav Haklai <nadavh@marvell.com>, Hanna Hawa <hannah@marvell.com>,
        Yehuda Yitschak <yehuday@marvell.com>,
        Stefan Chulski <stefanc@marvell.com>,
        Marcin Wojtas <mw@semihalf.com>,
        Antoine Tenart <antoine.tenart@free-electrons.com>,
        Jason Cooper <jason@lakedaemon.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        =?UTF-8?q?Miqu=C3=A8l=20Raynal?= <miquel.raynal@free-electrons.com>,
        linux-arm-kernel@lists.infradead.org,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:46620 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751758AbdHCIm2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 04:42:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

So far, the mvpp2 driver was using an hrtimer to handle TX
completion. This patch series adds support for using TX interrupts
(for each CPU) on PPv2.2, the variant of the IP used on Marvell Armada
7K/8K.

Dave: this version can be applied right away, it no longer depends on
Antoine's patch series. Antoine series had some comments, so he will
have to respin later on. Therefore, let's merge this smaller patch
series first.

Changes since v1:

 - Rebased on top of net-next, instead of on top of Antoine's series.

 - Removed the Device Tree patch, as it shouldn't go through the net
   tree.

Thanks!

Thomas

Thomas Petazzoni (7):
  net: mvpp2: fix MVPP21_ISR_RXQ_GROUP_REG definition
  net: mvpp2: remove RX queue group reset code
  net: mvpp2: introduce per-port nrxqs/ntxqs variables
  net: mvpp2: move from cpu-centric naming to "software thread" naming
  net: mvpp2: introduce queue_vector concept
  net: mvpp2: add support for TX interrupts and RX queue distribution
    modes
  dt-bindings: net: marvell-pp2: update interrupt-names with TX
    interrupts

 .../devicetree/bindings/net/marvell-pp2.txt        |  28 +-
 drivers/net/ethernet/marvell/mvpp2.c               | 611 ++++++++++++++++-----
 2 files changed, 488 insertions(+), 151 deletions(-)

-- 
2.9.4
