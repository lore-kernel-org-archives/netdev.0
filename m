From: Simon Guinot <simon.guinot@sequanux.org>
Subject: [PATCH v3 0/3] Fix Ethernet jumbo frames support for Armada 370 and 38x
Date: Tue, 30 Jun 2015 16:05:46 +0200
Message-ID: <1435673149-12599-1-git-send-email-simon.guinot@sequanux.org>
Cc: Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Vincent Donnefort <vdonnefort@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vm1.sequanux.org ([188.165.36.56]:57783 "EHLO vm1.sequanux.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753969AbbF3OF7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Jun 2015 10:05:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

This patch series fixes the Ethernet jumbo frames support for the SoCs
Armada 370, 380 and 385. Unlike Armada XP, the Ethernet controller for
this SoCs don't support TCP/IP checksumming with a frame size larger
than 1600 bytes.

This patches should be applied to the -stable kernels 3.8 and onwards.

Changes since v1:
- Use a new compatible string for the Ethernet IP found in Armada XP
  SoCs (instead of using an optional property).
- Fix the issue for the Armada 380 and 385 SoCs as well.

Changes since v2:
- Add Acked-by from Gregory Clement.
- Add "Fixes:" tag to each commits.

Regards,

Simon


Simon Guinot (3):
  net: mvneta: introduce compatible string "marvell,armada-xp-neta"
  ARM: mvebu: update Ethernet compatible string for Armada XP
  ARM: mvebu: disable IP checksum with jumbo frames for Armada 370

 .../bindings/net/marvell-armada-370-neta.txt       |  2 +-
 arch/arm/boot/dts/armada-370-xp.dtsi               |  2 --
 arch/arm/boot/dts/armada-370.dtsi                  |  8 +++++++
 arch/arm/boot/dts/armada-xp-mv78260.dtsi           |  2 +-
 arch/arm/boot/dts/armada-xp-mv78460.dtsi           |  2 +-
 arch/arm/boot/dts/armada-xp.dtsi                   | 10 +++++++-
 drivers/net/ethernet/marvell/mvneta.c              | 27 +++++++++++++++++++++-
 7 files changed, 46 insertions(+), 7 deletions(-)

-- 
2.1.4
