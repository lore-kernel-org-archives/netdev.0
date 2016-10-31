From: Neil Armstrong <narmstrong@baylibre.com>
Subject: [RFC PATCH v2 0/5] ARM64: Add Internal PHY support for Meson GXL
Date: Mon, 31 Oct 2016 17:56:22 +0100
Message-ID: <1477932987-27871-1-git-send-email-narmstrong@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devicetree@vger.kernel.org, Neil Armstrong <narmstrong@baylibre.com>,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-amlogic@lists.infradead.org, linux-arm-kernel@lists.infradead.org
To: f.fainelli@gmail.com, khilman@baylibre.com, carlo@caione.org,
 andrew@lunn.ch
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

The Amlogic Meson GXL SoCs have an internal RMII PHY that is muxed with the
external RGMII pins.

In order to support switching between the two PHYs links, extended registers
size for mdio-mux-mmioreg must be added.

Finally, the internal PHY is added in the GXL dtsi and support for each
board is added in intermediate board family dtsi or final dts.

This patchset depends on ARM64 dts patch at [1]

Changes since original RFC patchset at : [2]
 - Remove meson8b experimental phy switching
 - Switch to mdio-mux-mmioreg with extennded size support
 - Add internal phy support for S905x and p231
 - Add external PHY support for p230

[1] http://lkml.kernel.org/r/1477932286-27482-1-git-send-email-narmstrong@baylibre.com
[2] http://lkml.kernel.org/r/1477060838-14164-1-git-send-email-narmstrong@baylibre.com

Neil Armstrong (5):
  net: mdio-mux-mmioreg: Add support for 16bit and 32bit register sizes
  net: phy: Add Meson GXL Internal PHY driver
  ARM64: dts: meson-gxl: Add ethernet nodes with internal PHY
  ARM64: dts: meson-gxl-p23x: Enable ethernet
  ARM64: dts: meson-gxl-s905x: Enable internal ethernet PHY

 .../devicetree/bindings/net/mdio-mux-mmioreg.txt   |  4 +-
 .../boot/dts/amlogic/meson-gxl-s905d-p230.dts      | 16 +++++
 .../boot/dts/amlogic/meson-gxl-s905d-p231.dts      |  6 ++
 .../boot/dts/amlogic/meson-gxl-s905d-p23x.dtsi     |  4 ++
 arch/arm64/boot/dts/amlogic/meson-gxl-s905x.dtsi   |  6 ++
 arch/arm64/boot/dts/amlogic/meson-gxl.dtsi         | 45 ++++++++++++
 drivers/net/phy/Kconfig                            |  5 ++
 drivers/net/phy/Makefile                           |  1 +
 drivers/net/phy/mdio-mux-mmioreg.c                 | 60 ++++++++++++----
 drivers/net/phy/meson-gxl.c                        | 81 ++++++++++++++++++++++
 10 files changed, 213 insertions(+), 15 deletions(-)
 create mode 100644 drivers/net/phy/meson-gxl.c

-- 
1.9.1
