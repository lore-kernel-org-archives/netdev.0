From: Thierry Reding <thierry.reding-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v2 0/9] net: stmmac: Fixes and Tegra186 support
Date: Fri, 10 Mar 2017 17:34:52 +0100
Message-ID: <20170310163501.31811-1-thierry.reding@gmail.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
        Alexandre Torgue <alexandre.torgue-qxv4g6HH51o@public.gmane.org>,
        Joao Pinto <Joao.Pinto-HKixBCOQz3hWk0Htik3J/w@public.gmane.org>,
        Jon Hunter <jonathanh-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>,
        Mikko Perttunen <cyndis-/1wQRMveznE@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-tegra-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Thierry Reding <treding-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>

Hi everyone,

This series of patches start with a few cleanups that I ran across while
adding Tegra186 support to the stmmac driver. It then adds code for FIFO
size parsing from feature registers and finally enables support for the
incarnation of the Synopsys DWC QOS IP found on NVIDIA Tegra186 SoCs.

This is based on next-20170310.

Changes in v2:
- address review comments by Mikko and Joao
- add two additional cleanup patches

Thanks,
Thierry

Thierry Reding (9):
  net: stmmac: Rename clk_ptp_ref clock to ptp_ref
  net: stmmac: Stop PHY and remove TX timer on error
  net: stmmac: Disable PTP reference clock on error
  net: stmmac: Balance PTP reference clock enable/disable
  net: stmmac: Check for DMA mapping errors
  net: stmmac: Parse FIFO sizes from feature registers
  net: stmmac: Program RX queue size and flow control
  net: stmmac: dwc-qos: Split out ->probe() and ->remove()
  net: stmmac: dwc-qos: Add Tegra186 support

 Documentation/devicetree/bindings/net/stmmac.txt   |   6 +-
 drivers/net/ethernet/stmicro/stmmac/common.h       |   3 +
 .../ethernet/stmicro/stmmac/dwmac-dwc-qos-eth.c    | 371 +++++++++++++++++++--
 drivers/net/ethernet/stmicro/stmmac/dwmac4.h       |  15 +
 drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c   |  57 +++-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |  23 +-
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |   3 +-
 7 files changed, 444 insertions(+), 34 deletions(-)

-- 
2.12.0
