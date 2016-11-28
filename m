From: Jerome Brunet <jbrunet@baylibre.com>
Subject: [PATCH net-next v4 0/4] Fix OdroidC2 Gigabit Tx link issue
Date: Mon, 28 Nov 2016 16:50:24 +0100
Message-ID: <1480348229-25672-1-git-send-email-jbrunet@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Jerome Brunet <jbrunet@baylibre.com>,
        Carlo Caione <carlo@caione.org>,
        Kevin Hilman <khilman@baylibre.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre TORGUE <alexandre.torgue@st.com>,
        Martin Blumenstingl <martin.blumenstingl@googlemail.com>,
        Andre Roth <neolynx@gmail.com>, Andrew Lunn <andrew@lunn.ch>,
        Neil Armstrong <narmstrong@baylibre.com>,
        linux-amlogic@lists.infradead.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        Julia Lawall <julia.lawall@lip6.fr>,
        Yegor Yefremov <yegorslists@googlemail.com>,
        =?UTF-8?q?Andreas=20F=C3=A4rber?= <afaerber@suse.de>
To: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:35537 "EHLO
        mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754549AbcK1Pum (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 10:50:42 -0500
Received: by mail-wm0-f45.google.com with SMTP id a197so209536060wmd.0
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 07:50:41 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset fixes an issue with the OdroidC2 board (DWMAC + RTL8211F).
The platform seems to enter LPI on the Rx path too often while performing
relatively high TX transfer. This eventually break the link (both Tx and
Rx), and require to bring the interface down and up again to get the Rx
path working again.

The root cause of this issue is not fully understood yet but disabling EEE
advertisement on the PHY prevent this feature to be negotiated.
With this change, the link is stable and reliable, with the expected
throughput performance.

The patchset adds options in the generic phy driver to disable EEE
advertisement, through device tree. The way it is done is very similar
to the handling of the max-speed property.

Patch 4 is provided here for testing purpose only. Please don't merge
patch 4, this change will go through the amlogic's tree.

Chnages since V3: [3]
 - Fix signess error reported by kbuild test robot (Thx Julia)

Changes since V2: [2]
 - Rename "eee-advert-disable" to "eee-broken-modes" to make the intended
   purpose of this option clear (flag broken configuration, not a
   configuration option)
 - Add DT bindings constants so the DT configuration is more user friendly
 - Submit to net-next instead of net.

Changes since V1: [1]
 - Disable the advertisement of EEE in the generic code instead of the
   realtek driver.

[1] : http://lkml.kernel.org/r/1479220154-25851-1-git-send-email-jbrunet@baylibre.com
[2] : http://lkml.kernel.org/r/1479742524-30222-1-git-send-email-jbrunet@baylibre.com
[3] : http://lkml.kernel.org/r/1480326409-25419-1-git-send-email-jbrunet@baylibre.com

Jerome Brunet (4):
  net: phy: add an option to disable EEE advertisement
  dt-bindings: net: add EEE capability constants
  dt: bindings: add ethernet phy eee-broken-modes option documentation
  ARM64: dts: meson: odroidc2: disable advertisement EEE for GbE.

 Documentation/devicetree/bindings/net/phy.txt      |  2 +
 .../arm64/boot/dts/amlogic/meson-gxbb-odroidc2.dts | 14 ++++
 drivers/net/phy/phy.c                              |  3 +
 drivers/net/phy/phy_device.c                       | 80 +++++++++++++++++++---
 include/dt-bindings/net/mdio.h                     | 19 +++++
 include/linux/phy.h                                |  3 +
 6 files changed, 112 insertions(+), 9 deletions(-)
 create mode 100644 include/dt-bindings/net/mdio.h

-- 
2.7.4
