From: Jerome Brunet <jbrunet-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>
Subject: [PATCH net 0/3] Fix OdroidC2 Gigabit Tx link issue
Date: Tue, 15 Nov 2016 15:29:11 +0100
Message-ID: <1479220154-25851-1-git-send-email-jbrunet@baylibre.com>
Cc: Jerome Brunet <jbrunet-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>,
        Carlo Caione <carlo-KA+7E9HrN00dnm+yROfE0A@public.gmane.org>,
        Kevin Hilman <khilman-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>,
        Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
        Alexandre TORGUE <alexandre.torgue-qxv4g6HH51o@public.gmane.org>,
        Martin Blumenstingl <martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>,
        Andre Roth <neolynx-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Neil Armstrong <narmstrong-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>,
        linux-amlogic-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
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

The patchset adds options in the realtek phy driver to disable EEE
advertisement, through device tree, for the phy version supporting EEE.
Then EEE is disabled in the OdroidC2 device tree for Gigabit speed.
100M is not affected by this issue.

Jerome Brunet (3):
  net: phy: realtek: add eee advertisement disable options
  dt-bindings: net: add DT bindings for realtek phys
  ARM64: dts: meson: odroidc2: disable 1000t-eee advertisement

 .../devicetree/bindings/net/realtek-phy.txt        | 20 +++++++
 .../arm64/boot/dts/amlogic/meson-gxbb-odroidc2.dts | 15 +++++
 drivers/net/phy/realtek.c                          | 65 +++++++++++++++++++++-
 3 files changed, 99 insertions(+), 1 deletion(-)
 create mode 100644 Documentation/devicetree/bindings/net/realtek-phy.txt

-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
