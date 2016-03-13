From: Caesar Wang <wxt@rock-chips.com>
Subject: [PATCH v2 0/9] arc_emac: fixes the emac issues and cleanup emac drivers
Date: Sun, 13 Mar 2016 17:07:33 +0800
Message-ID: <1457860062-5514-1-git-send-email-wxt@rock-chips.com>
Cc: linux-rockchip@lists.infradead.org, keescook@google.com,
	leozwang@google.com, sergei.shtylyov@cogentembedded.com,
	netdev@vger.kernel.org, Caesar Wang <wxt@rock-chips.com>,
	devicetree@vger.kernel.org,
	Michael Turquette <mturquette@baylibre.com>,
	Alexander Kochetkov <al.kochet@gmail.com>,
	Russell King <linux@arm.linux.org.uk>,
	Stephen Boyd <sboyd@codeaurora.org>,
	Kumar Gala <galak@codeaurora.org>,
	linux-kernel@vger.kernel.org,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Jiri Kosina <trivial@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>, linux-clk@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	Xing Zheng <zhengxing@rock-chips.com>
To: Heiko Stuebner <heiko@sntech.de>,
	"David S. Miller" <davem@davemloft.net>,
	Rob Herring <robh+dt@kernel.org>
Return-path: <linux-clk-owner@vger.kernel.org>
Sender: linux-clk-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,
This series patches are based on kernel 4.5-rc7+ version.
Linux version 4.5.0-rc7-next-20160311+ (wxt@nb) (...) #45 SMP Sun Mar 13 16:17:56

The history patch in here:
Patch-v1: https://lkml.org/lkml/2016/3/11/209

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

1) This series has 6 patches: (1--->9)
net: arc_emac: make the rockchip emac document more compatible
net: arc_emac: add phy reset is optional for device tree
net: arc_emac: support the phy reset for emac driver
net: arc: trivial: cleanup the emac driver
clk: rockchip: add node-id for rk3036 emac hclk
clk: rockchip: associate the rk3036 HCLK_EMAC clock-id
clk: rockchip: add clock-id for rk3036 emac pll source clock
clk: rockchip: associate SCLK_MAC_PLL and disable reparenting on rk3036
ARM: dts: rockchip: add support emac for RK3036

2) This series patches have the following descriptions:

Hi Rob, David:
PATCH[1/9-2/9]: ====>
net: arc_emac: make the rockchip emac document more compatible
net: arc_emac: add phy reset is optional for device tree

The patches change the rockchip emac document for more compatible and
Add the phy reset property for document.
---

Hi David
PATCH[3/9]: ====>
net: arc_emac: support the phy reset for emac driver

The emac didn't work on kylin board since in some case the clocks parent changed.
The kylin hardware connects the phy reset pin, we should use it with real world.
As the previous patch discuss on https://patchwork.kernel.org/patch/8186801/

And as sergei/Heiko suggestions on
https://patchwork.kernel.org/patch/8564571/
---

Hi David
PATCH[4/9]: ====>
net: arc: trivial: cleanup the emac driver

The first time to look the emac drivers, I think that have to cleanup the drivers with scripts.
Although it's the trivial things, in order to be more read.
---

Hi Heiko,Michael,Stephen:
PATCH[5/9-8/9]: ====> clk: rockchip: rk3036: fix and add node id for emac clock

Four-part from https://patchwork.kernel.org/patch/8564581/
clk: rockchip: add node-id for rk3036 emac hclk
clk: rockchip: associate the rk3036 HCLK_EMAC clock-id
clk: rockchip: add clock-id for rk3036 emac pll source clock
clk: rockchip: associate SCLK_MAC_PLL and disable reparenting on rk3036

Add the emac needed clocks for rk3036 SOCs
---

Hi Heiko:
PATCH[9/9]: ====>
ARM: dts: rockchip: add support emac for RK3036

Add the emac needed main info for rk3036 dts.
---

Thanks your reviewing! :)


Changes in v2:
- change the commit and remove the repeat the name 'rockchip'.
- As the pervious version, Sergei and Heiko comments on
  https://patchwork.kernel.org/patch/8564571/.
- Nevermind, add signed-off since Heiko the original patch,
  refer the Heiko's test patch on
  https://github.com/mmind/linux-rockchip/commit/a943c588783438ff1c508dfa8c79f1709aa5775e
  :)
- As the robot notice the build error since overflow in implicit
  constant conversion.

Caesar Wang (4):
  net: arc_emac: make the rockchip emac document more compatible
  net: arc_emac: add phy reset is optional for device tree
  net: arc_emac: support the phy reset for emac driver
  net: arc: trivial: cleanup the emac driver

Heiko Stuebner (1):
  clk: rockchip: associate SCLK_MAC_PLL and disable reparenting on
    rk3036

Xing Zheng (3):
  clk: rockchip: add node-id for rk3036 emac hclk
  clk: rockchip: associate the rk3036 HCLK_EMAC clock-id
  clk: rockchip: add clock-id for rk3036 emac pll source clock

zhengxing (1):
  ARM: dts: rockchip: add support emac for RK3036

 Documentation/devicetree/bindings/net/arc_emac.txt |  7 +++
 .../devicetree/bindings/net/emac_rockchip.txt      |  8 +--
 arch/arm/boot/dts/rk3036-evb.dts                   | 23 +++++++++
 arch/arm/boot/dts/rk3036-kylin.dts                 | 20 ++++++++
 arch/arm/boot/dts/rk3036.dtsi                      | 39 ++++++++++++++
 drivers/clk/rockchip/clk-rk3036.c                  |  4 +-
 drivers/net/ethernet/arc/emac.h                    | 60 ++++++++++++----------
 drivers/net/ethernet/arc/emac_main.c               | 35 ++++++-------
 drivers/net/ethernet/arc/emac_mdio.c               | 38 +++++++++++++-
 drivers/net/ethernet/arc/emac_rockchip.c           | 41 ++++++++++-----
 include/dt-bindings/clock/rk3036-cru.h             |  2 +
 11 files changed, 215 insertions(+), 62 deletions(-)

-- 
1.9.1

