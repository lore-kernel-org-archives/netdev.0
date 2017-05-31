From: Leonard Crestez <leonard.crestez@nxp.com>
Subject: [PATCH v2 0/2] ARM: imx6ul-14x14-evk: Fix suspend over nfs by phy
Date: Wed, 31 May 2017 13:29:28 +0300
Message-ID: <cover.1496224930.git.leonard.crestez@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Andy Duan <fugang.duan@nxp.com>, Johan Hovold <johan@kernel.org>,
        Alexandre Belloni <alexandre.belloni@free-electrons.com>,
        Philipp Zabel <p.zabel@pengutronix.de>,
        Fabio Estevam <fabio.estevam@nxp.com>,
        <netdev@vger.kernel.org>, <linux-arm-kernel@lists.infradead.org>,
        <linux-kernel@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>, Shawn Guo <shawnguo@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Right now attempting doing suspend/resume while root is mounted over NFS
hangs on imx6ul-14x14-evk. This is happening because ksz8081 phy fixups are
lost on resume.

Fix this by using equivalent devicetree properties instead of a phy fixup
and handling those properties on resume in the micrel driver.

In theory it might now be possible to remove the phy fixup from mach-imx6ul
entirely but it is possible that this would break other imx6ul boards which
use the same phy. The solution would be to patch their dts but it's not
clear how to identify affected boards.

This code is shared with imx6ull-14x14-evk but 6ull suspend needs an
unrelated patch: https://lkml.org/lkml/2017/5/30/584

This is something of a corner case so there is no CC: stable.

Changes since v1: https://lkml.org/lkml/2017/5/30/672 
 * Split a kszphy_config_reset function for stuff shared between
config_init and resume. Calling config_init directly could be an option but
on some HW variants it does extra stuff like parsing devicetree options.
That would not be appropriate for resume code.

Leonard Crestez (2):
  ARM: dts: imx6ul-14x14-evk: Add ksz8081 phy properties
  net: phy: micrel: Restore led_mode and clk_sel on resume

 arch/arm/boot/dts/imx6ul-14x14-evk.dts |  6 +++++
 drivers/net/phy/micrel.c               | 42 ++++++++++++++++++++++------------
 2 files changed, 34 insertions(+), 14 deletions(-)

-- 
2.7.4
