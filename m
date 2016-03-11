From: Caesar Wang <wxt@rock-chips.com>
Subject: [PATCH 0/6] arc_emac: fixes the emac issues oand cleanup emac drivers
Date: Fri, 11 Mar 2016 18:55:25 +0800
Message-ID: <1457693731-6966-1-git-send-email-wxt@rock-chips.com>
Cc: linux-rockchip@lists.infradead.org, keescook@google.com,
	leozwang@google.com, Caesar Wang <wxt@rock-chips.com>,
	devicetree@vger.kernel.org,
	Michael Turquette <mturquette@baylibre.com>,
	Alexander Kochetkov <al.kochet@gmail.com>,
	Russell King <linux@arm.linux.org.uk>,
	Stephen Boyd <sboyd@codeaurora.org>, netdev@vger.kernel.org,
	Kumar Gala <galak@codeaurora.org>,
	linux-kernel@vger.kernel.org,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	zhengxing <zhengxing@rock-chips.com>,
	Jiri Kosina <trivial@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>, linux-clk@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Heiko Stuebner <heiko@sntech.de>,
	"David S. Miller" <davem@davemloft.net>,
	Rob Herring <robh+dt@kernel.org>
Return-path: <linux-clk-owner@vger.kernel.org>
Sender: linux-clk-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This series patches are based on kernel 4.5-rc7+ version.
Linux version 4.5.0-rc7-next-20160310+ (wxt@nb) (...) #23 SMP Fri Mar 11 15:55:53

Verified on kylin board with my github.
https://github.com/Caesar-github/rockchip/tree/kylin/next

That's verified on kylin board with ubuntu os.

How to test and verify?

You can refer to the following wiki document.
http://rockchip.wikidot.com/linux-develop-guide

bootup log:
   1.268113] rockchip_emac 10200000.ethernet: no regulator found
   [    1.286682] rockchip_emac 10200000.ethernet: ARC EMAC detected with id: 0x7fd02
   [    1.294007] rockchip_emac 10200000.ethernet: IRQ is 29
   [    1.299453] rockchip_emac 10200000.ethernet: MAC address is now 1e:cd:18:78:90:25
   [    1.726564] rockchip_emac 10200000.ethernet: connected to Generic PHY phy with id 0x1cc816
   [    8.936862] rockchip_emac 10200000.ethernet eth0: Link is Up - 100Mbps/Full - flow control off

root@localhost:/# busybox ping www.baidu.com
PING www.baidu.com (14.215.177.38): 56 data bytes
64 bytes from 14.215.177.38: seq=0 ttl=48 time=35.046 ms
64 bytes from 14.215.177.38: seq=1 ttl=48 time=35.095 ms
64 bytes from 14.215.177.38: seq=2 ttl=48 time=34.203 ms
64 bytes from 14.215.177.38: seq=3 ttl=48 time=38.516 ms
...
---

1) This series has 6 patches: (1--->6)
net: arc_emac: make the rockchip emac document more compatible
net: arc_emac: add phy-reset-* are optional for device tree
net: arc_emac: support the phy reset for emac driver
net: arc: trivial: cleanup the emac driver
clk: rockchip: rk3036: fix and add node id for emac clock
ARM: dts: rockchip: add support emac for RK3036

2) This series patches have the following decriptions:

Hi Rob, David:
PATCH[1/6-2/6]: ====>
net: arc_emac: make the rockchip emac document more compatible
net: arc_emac: add phy-reset-* are optional for device tree

The patches change the rockchip emac document for more compatible and
Add the phy-reset-* property for document.

This patch adds the following property for arc_emac.

phy-reset-* include the following:
1) phy-reset-gpios:
The phy-reset-gpios is an optional property for arc emac device tree boot.
Change the binding document to match the driver code.

2) phy-reset-duration:
Different boards may require different phy reset duration. Add property
phy-reset-duration for device tree probe, so that the boards that need
a longer reset duration can specify it in their device tree.

3) phy-reset-active-high:
We need that for a custom hardware that needs the reverse reset sequence.
---

Hi David
PATCH[3/6]: ====>
net: arc_emac: support the phy reset for emac driver

The emac didn't work on kylin board since in some case the clocks parent changed.
The kylin hardware connects the phy reset pin, we should use it with real world.

As the previous patch discuss on https://patchwork.kernel.org/patch/8186801/

Hi David
PATCH[4/6]: ====>
net: arc: trivial: cleanup the emac driver

The first time to look the emac drivers, I think that have to cleanup the drivers with scripts.
Although it's the trivial things, in order to be more read.
---

Hi Heiko,Michael,Stephen:
PATCH[5/6]: ====>
clk: rockchip: rk3036: fix and add node id for emac clock

Add the emac needed clocks for rk3036 SOCs
---

Hi Heiko:
PATCH[6/6]: ====>
ARM: dts: rockchip: add support emac for RK3036

Add the emac node info for rk3036 dts/dtsi.
---

Thanks your reviewing! :)



Caesar Wang (4):
  net: arc_emac: make the rockchip emac document more compatible
  net: arc_emac: add phy-reset-* are optional for device tree
  net: arc_emac: support the phy reset for emac driver
  net: arc: trivial: cleanup the emac driver

zhengxing (2):
  clk: rockchip: rk3036: fix and add node id for emac clock
  ARM: dts: rockchip: add support emac for RK3036

 Documentation/devicetree/bindings/net/arc_emac.txt | 10 +++
 .../devicetree/bindings/net/emac_rockchip.txt      |  8 ++-
 arch/arm/boot/dts/rk3036-evb.dts                   | 23 +++++++
 arch/arm/boot/dts/rk3036-kylin.dts                 | 20 ++++++
 arch/arm/boot/dts/rk3036.dtsi                      | 39 +++++++++++
 drivers/clk/rockchip/clk-rk3036.c                  |  9 ++-
 drivers/net/ethernet/arc/emac.h                    | 54 +++++++--------
 drivers/net/ethernet/arc/emac_main.c               | 76 +++++++++++++++++-----
 drivers/net/ethernet/arc/emac_mdio.c               |  2 +-
 drivers/net/ethernet/arc/emac_rockchip.c           | 41 ++++++++----
 include/dt-bindings/clock/rk3036-cru.h             |  2 +
 11 files changed, 221 insertions(+), 63 deletions(-)

-- 
1.9.1

