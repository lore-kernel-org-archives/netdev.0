From: Leonard Crestez <leonard.crestez@nxp.com>
Subject: [PATCH 0/2] ARM: imx6ul-14x14-evk: Fix suspend over nfs by phy cleanup
Date: Tue, 30 May 2017 20:34:02 +0300
Message-ID: <cover.1496164448.git.leonard.crestez@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Johan Hovold <johan@kernel.org>,
        Alexandre Belloni <alexandre.belloni@free-electrons.com>,
        Philipp Zabel <p.zabel@pengutronix.de>,
        Fabio Estevam <fabio.estevam@nxp.com>,
        <netdev@vger.kernel.org>, <linux-arm-kernel@lists.infradead.org>,
        <linux-kernel@vger.kernel.org>
To: Shawn Guo <shawnguo@kernel.org>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>, Andy Duan <fugang.duan@nxp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Right now attempting doing suspend/resume while root is mounted over NFS hangs
on imx6ul-14x14-evk. This is happening because ksz8081 phy fixups are lost on
resume.

Fix this by using equivalent devicetree properties instead of a phy fixup and
handling those properties on resume in the micrel driver.

Other solutions would be possible such as having a way to run phy fixups again
on resume. This alternative is precisely targeted.

In theory it might now be possible to remove the phy fixup from mach-imx6ul
entirely but it is possible that this would break other imx6ul boards which use
the same phy. The solution would be to patch their dts but it's not clear how
to identify affected boards.

This code is shared with imx6ull-14x14-evk but 6ull suspend needs an unrelated
patch: https://lkml.org/lkml/2017/5/30/584

Leonard Crestez (2):
  ARM: dts: imx6ul-14x14-evk: Add ksz8081 phy properties
  net: phy: micrel: Restore led_mode and clk_sel on resume

 arch/arm/boot/dts/imx6ul-14x14-evk.dts |  6 ++++++
 drivers/net/phy/micrel.c               | 15 +++++++++++++++
 2 files changed, 21 insertions(+)

-- 
2.7.4
