From: Johan Hovold <johan@kernel.org>
Subject: [PATCH net 0/7] net: stmmac: fix probe error handling and phydev leaks
Date: Wed, 30 Nov 2016 15:29:48 +0100
Message-ID: <1480516195-27696-1-git-send-email-johan@kernel.org>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        Joachim Eastwood <manabian@gmail.com>,
        Carlo Caione <carlo@caione.org>,
        Kevin Hilman <khilman@baylibre.com>,
        Maxime Coquelin <mcoquelin.stm32@gmail.com>,
        Maxime Ripard <maxime.ripard@free-electrons.com>,
        Chen-Yu Tsai <wens@csie.org>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Johan Hovold <johan@kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:35855 "EHLO
        mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753958AbcK3Ocd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 09:32:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series fixes a number of issues with the stmmac-driver probe error
handling, which for example left clocks enabled after probe failures.

The final patch fixes a failure to deregister and free any fixed-link
PHYs that were registered during probe on probe errors and on driver
unbind. It also fixes a related of-node leak on late probe errors.

This series depends on the of_phy_deregister_fixed_link() helper that
was just merged to net.

As mentioned earlier, one staging driver also suffers from a similar
leak and can be fixed up once the above mentioned helper hits mainline.

Note that these patches have only been compile tested.

Johan


Johan Hovold (7):
  net: ethernet: stmmac: dwmac-socfpga: fix use-after-free on probe
    errors
  net: ethernet: stmmac: dwmac-sti: fix probe error path
  net: ethernet: stmmac: dwmac-rk: fix probe error path
  net: ethernet: stmmac: dwmac-generic: fix probe error path
  net: ethernet: stmmac: dwmac-meson8b: fix probe error path
  net: ethernet: stmmac: platform: fix outdated function header
  net: ethernet: stmmac: fix of-node and fixed-link-phydev leaks

 .../net/ethernet/stmicro/stmmac/dwmac-generic.c    | 17 ++++++++--
 .../net/ethernet/stmicro/stmmac/dwmac-ipq806x.c    | 25 ++++++++++----
 .../net/ethernet/stmicro/stmmac/dwmac-lpc18xx.c    | 17 ++++++++--
 drivers/net/ethernet/stmicro/stmmac/dwmac-meson.c  | 23 ++++++++++---
 .../net/ethernet/stmicro/stmmac/dwmac-meson8b.c    | 32 +++++++++++++-----
 drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c     | 21 +++++++++---
 .../net/ethernet/stmicro/stmmac/dwmac-socfpga.c    | 39 ++++++++++++++--------
 drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c    | 23 ++++++++++---
 drivers/net/ethernet/stmicro/stmmac/dwmac-stm32.c  | 19 ++++++++---
 drivers/net/ethernet/stmicro/stmmac/dwmac-sunxi.c  | 26 +++++++++++----
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |  1 -
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  | 33 +++++++++++++++---
 .../net/ethernet/stmicro/stmmac/stmmac_platform.h  |  2 ++
 13 files changed, 215 insertions(+), 63 deletions(-)

-- 
2.7.3
