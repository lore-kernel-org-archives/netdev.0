From: Joel Stanley <joel@jms.id.au>
Subject: [PATCH net-next v2 0/6]  ftgmac100 support for ast2500
Date: Thu, 22 Sep 2016 08:34:57 +0930
Message-ID: <20160921230503.23309-1-joel@jms.id.au>
Cc: clg@kaod.org, gwshan@linux.vnet.ibm.com, andrew@lunn.ch,
        andrew@aj.id.au, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, benh@kernel.crashing.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:34890 "EHLO
        mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756419AbcIUXFU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2016 19:05:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Dave,

This series adds support to the ftgmac100 driver for the Aspeed ast2400 and
ast2500 SoCs. In particular, they ensure the driver works correctly on the
ast2500 where the MAC block has seen some changes in register layout.

They have been tested on ast2400 and ast2500 systems with the NCSI stack and
with a directly attached PHY.

V2 reworks the two patches relating to PHYSTS_CHG into the one patch that
disables the interrupt instead of playing with interrupt sensitivity. I kept
patch 4 'net/faraday: Clear stale interrupts' which was first introduced to
clear the stale PHYSTS_CHG interrupt, as it helps keep us safe from unhygienic
(vendor) bootloaders.

Cheers,

Joel

Andrew Jeffery (2):
  net/faraday: Separate rx page storage from rxdesc
  net/faraday: Make EDO{R,T}R bits configurable

Gavin Shan (1):
  net/faraday: Clear stale interrupts

Joel Stanley (3):
  net/faraday: Adapt for Aspeed SoCs
  net/faraday: Configure old MDIO interface on Aspeed SoCs
  net/faraday: Mask out PHYSTS_CHG interrupt

 drivers/net/ethernet/faraday/ftgmac100.c | 97 +++++++++++++++++++++++---------
 drivers/net/ethernet/faraday/ftgmac100.h |  8 ++-
 2 files changed, 75 insertions(+), 30 deletions(-)

-- 
2.9.3
