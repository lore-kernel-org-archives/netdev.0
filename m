From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [RFC/RFT PATCH 0/4] net: ethernat: ti: cpts: enable irq and HW_TS_PUSH
Date: Tue, 13 Jun 2017 18:16:19 -0500
Message-ID: <20170613231623.28353-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <linux-omap@vger.kernel.org>,
        <ivan.khoronzhuk@linaro.org>,
        Grygorii Strashko <grygorii.strashko@ti.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Sekhar Nori <nsekhar@ti.com>,
        Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Intention of this post is to get some early review and wider testing.

This series adds CPTS IRQ support, which allows to fix TX timestamping issue
and add support for HW_TS_PUSH events.

The idea of using CPTS IRQ for proper support of HW_TS_PUSH events
was originally discussed in [1].

Further TX timestamping issue was discovered and enabling of CPTS IRQ allows to
fix it also.
 - TX timestamp can be missed with the low Ethernet link connection speed.
In this case CPDMA notification about packet processing can be received before
CPTS TX timestamp event, which is sent when packet actually left CPSW while
cpdma notification is sent when packet pushed in CPSW fifo. 
As result, when connection is slow and CPU is fast enough TX timestamping is not
working properly. Issue was discovered on am57x boards with Ethernet link
connection speed forced to 100M and on am335x-evm with thernet link
connection speed forced to 10M using timestamping tool.

PATCH 4: provided to illustrate how HW_TS_PUSH can be used.

I've tested it on am57/dra7 and am335.

!!! Unfortunatelly, I still trying to enable CPTS IRQ on Keystone 2 and
this is blocker for now.

Series based on top of net-next tree,
commit a1fa1a0 net: phy: marvell: Show complete link partner advertising.

[1] https://www.mail-archive.com/netdev@vger.kernel.org/msg141466.html

Grygorii Strashko (4):
  net: ethernet: ti: cpts: use own highpri workqueue
  net: ethernat: ti: cpts: enable irq
  net: ethernet: ti: cpts: add support of cpts HW_TS_PUSH
  [debug] ARM: am335x: illustrate hwstamp

 Documentation/devicetree/bindings/net/cpsw.txt     |   4 +
 .../devicetree/bindings/net/keystone-netcp.txt     |   6 +
 arch/arm/boot/dts/am335x-boneblack.dts             |   6 +
 arch/arm/boot/dts/am335x-evm.dts                   |   7 +
 arch/arm/boot/dts/am33xx.dtsi                      |   1 +
 arch/arm/configs/omap2plus_defconfig               |   2 +-
 drivers/net/ethernet/ti/cpsw.c                     |  42 +-
 drivers/net/ethernet/ti/cpts.c                     | 432 ++++++++++++++++-----
 drivers/net/ethernet/ti/cpts.h                     |  23 +-
 9 files changed, 409 insertions(+), 114 deletions(-)

-- 
2.10.1
