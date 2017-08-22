From: Icenowy Zheng <icenowy-h8G6r0blFSE@public.gmane.org>
Subject: [PATCH v2 0/4] Workaround broken RTL8211E on some
 Pine64+ boards
Date: Tue, 22 Aug 2017 12:03:56 +0800
Message-ID: <20170822040400.12166-1-icenowy@aosc.io>
Reply-To: icenowy-h8G6r0blFSE@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org,
	Icenowy Zheng <icenowy-h8G6r0blFSE@public.gmane.org>
To: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>,
	Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-sunxi+bncBDS6XAN6ZADRBRW253GAKGQEF4DHLPY-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

Some Pine64+ boards come with bad RTL8211E PHYs, which cannot work reliably
unless do some hack. According to Pine64 people, Realtek describes the hack
as totally disabling RX delay, and it's not documented at all.

This patchset introduces the workaround on Pine64+.

The first patch adds RGMII variants' support to the dwmac-sun8i driver.

The second patch renames some macros in RTL PHY driver, and the third
patch introduces the hack as the "RGMII-TXID" mode of the PHY.

The fourth patch enables the hack in the device tree.

Icenowy Zheng (4):
  net: stmmac: dwmac-sun8i: support RGMII modes with PHY internal delay
  net: phy: realtek: change macro name for page select register
  net: phy: realtek: add disable RX internal delay mode
  arm64: allwinner: a64: disable the RTL8211E internal RX delay on
    Pine64+

 .../boot/dts/allwinner/sun50i-a64-pine64-plus.dts  |  2 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac-sun8i.c  |  3 ++
 drivers/net/phy/realtek.c                          | 43 +++++++++++++++++++---
 3 files changed, 42 insertions(+), 6 deletions(-)

-- 
2.13.5
