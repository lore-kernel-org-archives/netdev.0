From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCHv2 net-next 00/16] net: mvpp2: add basic support for PPv2.2
Date: Wed, 28 Dec 2016 17:46:16 +0100
Message-ID: <1482943592-12556-1-git-send-email-thomas.petazzoni@free-electrons.com>
Cc: Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        Nadav Haklai <nadavh@marvell.com>,
        Hanna Hawa <hannah@marvell.com>,
        Yehuda Yitschak <yehuday@marvell.com>,
        linux-arm-kernel@lists.infradead.org,
        Stefan Chulski <stefanc@marvell.com>,
        Marcin Wojtas <mw@semihalf.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        devicetree@vger.kernel.org, Rob Herring <robh+dt@kernel.org>,
        Ian Campbell <ijc+devicetree@hellion.org.uk>,
        Pawel Moll <pawel.moll@arm.com>,
        Mark Rutland <mark.rutland@arm.com>,
        Kumar Gala <galak@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:47647 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750966AbcL1QsB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Dec 2016 11:48:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

The goal of this patch series is to add basic support for PPv2.2 in
the existing mvpp2 driver. mvpp2 currently supported the PPv2.1
version of the IP, used in the 32 bits Marvell Armada 375 SoC. PPv2.2
is an evolution of this IP block, used in the 64 bits Marvell Armada
7K/8K SoCs.

In order to ease the review, the introduction of PPv2.2 support has
been made into multiple small commits, with the final commit adding
the compatible string that makes the PPv2.2 support actually
usable. The series remain fully bisectable.

This series depends on the series named "net: mvpp2: misc improvements
and preparation patches".

I'd like to thank Stefan Chulski and Marcin Wojtas, who helped me a
lot in the development of this patch series, by reviewing the patches,
and giving lots of useful hints to debug the driver on PPv2.2. Thanks!

Changes since v1:

 - Made a separate series from the set of patches doing preparation
   changes/fixes to the mvpp2 driver.

 - Rebased on top of v4.10-rc1.

 - Update Kconfig text of the mvpp2 driver to mention the support for
   Armada 7K and 8K (PPv2.2).

Best regards,

Thomas

Thomas Petazzoni (16):
  dt-bindings: net: update Marvell PPv2 binding for PPv2.2 support
  net: mvpp2: add and use accessors for TX/RX descriptors
  net: mvpp2: add hw_version field in "struct mvpp2"
  net: mvpp2: introduce an intermediate union for the TX/RX descriptors
  net: mvpp2: introduce PPv2.2 HW descriptors and adapt accessors
  net: mvpp2: adjust the allocation/free of BM pools for PPv2.2
  net: mvpp2: adapt the mvpp2_rxq_*_pool_set functions to PPv2.2
  net: mvpp2: adapt mvpp2_defaults_set() to PPv2.2
  net: mvpp2: adjust mvpp2_{rxq,txq}_init for PPv2.2
  net: mvpp2: handle register mapping and access for PPv2.2
  net: mvpp2: handle misc PPv2.1/PPv2.2 differences
  net: mvpp2: add AXI bridge initialization for PPv2.2
  net: mvpp2: rework RXQ interrupt group initialization for PPv2.2
  net: mvpp2: adapt rxq distribution to PPv2.2
  net: mvpp2: add support for an additional clock needed for PPv2.2
  net: mvpp2: finally add the PPv2.2 compatible string

 .../devicetree/bindings/net/marvell-pp2.txt        |  66 +-
 drivers/net/ethernet/marvell/Kconfig               |   4 +-
 drivers/net/ethernet/marvell/mvpp2.c               | 783 +++++++++++++++++----
 3 files changed, 700 insertions(+), 153 deletions(-)

-- 
2.7.4
