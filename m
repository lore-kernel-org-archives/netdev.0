From: Jerome Brunet <jbrunet@baylibre.com>
Subject: [RFC PATCH net v2 0/3] Fix OdroidC2 Gigabit Tx link issue
Date: Mon, 21 Nov 2016 16:35:21 +0100
Message-ID: <1479742524-30222-1-git-send-email-jbrunet@baylibre.com>
Cc: Jerome Brunet <jbrunet@baylibre.com>,
        Carlo Caione <carlo@caione.org>,
        Kevin Hilman <khilman@baylibre.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre TORGUE <alexandre.torgue@st.com>,
        Martin Blumenstingl <martin.blumenstingl@googlemail.com>,
        Andre Roth <neolynx@gmail.com>,
        Neil Armstrong <narmstrong@baylibre.com>,
        linux-amlogic@lists.infradead.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset fixes an issue with the OdroidC2 board (DWMAC + RTL8211F).
Initially reported as a low Tx throughput issue at gigabit speed, the
platform enters LPI too often. This eventually break the link (both Tx
and Rx), and require to bring the interface down and up again to get the
Rx path working again.

The root cause of this issue is not fully understood yet but disabling EEE
advertisement on the PHY prevent this feature to be negotiated.
With this change, the link is stable and reliable, with the expected
throughput performance.

The patchset adds options in the generic phy driver to disable EEE
advertisement, through device tree. The way it is done is very similar
to the handling of the max-speed property.

This V2 is posted is posted as an RFC. Since it changes the generic PHY
it propably requires to be a bit more careful.
If you are not confortable taking for the coming rc, I can rebase on
net-next instead.

Chnages since V1: [1]
 - Disable the advertisement of EEE in the generic code instead of the
   realtek driver.

[1] : http://lkml.kernel.org/r/1479220154-25851-1-git-send-email-jbrunet@baylibre.com

Jerome Brunet (3):
  net: phy: add an option to disable EEE advertisement
  dt: bindings: add ethernet phy eee-disable-advert option documentation
  ARM64: dts: meson: odroidc2: disable advertisement EEE for GbE.

 Documentation/devicetree/bindings/net/phy.txt      |  5 ++
 .../arm64/boot/dts/amlogic/meson-gxbb-odroidc2.dts | 15 ++++
 drivers/net/phy/phy.c                              |  3 +
 drivers/net/phy/phy_device.c                       | 80 +++++++++++++++++++---
 include/linux/phy.h                                |  3 +
 5 files changed, 97 insertions(+), 9 deletions(-)

-- 
2.7.4
