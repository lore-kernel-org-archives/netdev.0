From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH] [v6] net: emac: emac gigabit ethernet controller driver
Date: Tue, 28 Jun 2016 15:56:00 -0500
Message-ID: <20160628205600.GK3737@rob-hp-laptop>
References: <1466812008-26686-1-git-send-email-timur@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	linux-arm-msm@vger.kernel.org, sdharia@codeaurora.org,
	shankerd@codeaurora.org, vikrams@codeaurora.org,
	cov@codeaurora.org, gavidov@codeaurora.org, andrew@lunn.ch,
	bjorn.andersson@linaro.org, mlangsdo@redhat.com, jcm@redhat.com,
	agross@codeaurora.org, davem@davemloft.net, f.fainelli@gmail.com
To: Timur Tabi <timur@codeaurora.org>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1466812008-26686-1-git-send-email-timur@codeaurora.org>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 24, 2016 at 06:46:48PM -0500, Timur Tabi wrote:
> Add supports for ethernet controller HW on Qualcomm Technologies, Inc. SoC.
> This driver supports the following features:
> 1) Checksum offload.
> 2) Interrupt coalescing support.
> 3) SGMII phy.
> 4) phylib interface for external phy
> 
> Based on original work by
> 	Niranjana Vishwanathapura <nvishwan@codeaurora.org>
> 	Gilad Avidov <gavidov@codeaurora.org>
> 
> Signed-off-by: Timur Tabi <timur@codeaurora.org>
> ---
> 
> v6:
>  - Properly ordered local variables
>  - use built-in GEN_MASK instead of BITS_MASK
>  - remove redundant call to emac_rx_mode_set from emac_mac_up
>  - removed emac_rfd structure, use dma_addr_t directly instead
>  - removed emac_mac_speed enun, replaced with macros
>  - removed superfluous phy_stop from emac_mac_down(), which prevented reloading module
>  - add missing netif_napi_del
>  - set the DMA mask
> 
> v5:
>  - changed author to Timur, added MAINTAINERS entry
>  - use phylib, replacing internal phy code
>  - added support for EMAC internal SGMII v2
>  - fix ~DIS_INT warning
>  - update DT bindings, including removing unused properties
>  - removed interrupt handler for internal sgmii
>  - removed link status check handler/state (replaced with phylib)
>  - removed periodic timer handler (replaced with phylib)
>  - removed power management code (will be rewritten later)
>  - external phy is now required, not optional
>  - removed redundant EMAC_STATUS_DOWN status flag
>  - removed redundant link status and speed variables
>  - removed redundant status bits (vlan strip, promiscuous, loopback, etc)
>  - removed useless watchdog status
>  - removed command-line parameters
>  - cleaned up probe messages
>  - removed redundant params from emac_sgmii_link_init()
>  - always call netdev_completed_queue() (per review comment)
>  - fix emac_napi_rtx() (per review comment)
>  - removed max_ints loop in interrupt handler
>  - removed redundant mutex around phy read/write calls
>  - added lock for reading emac status (per review comment)
>  - generate random MAC address if it can't be read from firmware
>  - replace EMAC_DMA_ADDR_HI/LO with upper/lower_32_bits
>  - don't test return value from platform_get_resource (per review comment)
>  - use net_warn_ratelimited (per review comment)
>  - don't set the dma masks (will be set by DT or IORT code)
>  - remove unused emac_tx_tpd_ts_save()
>  - removed redundant local MTU variable
> 
> v4:
>  - add missing ipv6 header file
>  - correct compatible string
>  - fix spacing in emac_reg_write arrays
>  - drop unnecessary cell-index property
>  - remove unsupported DT properties from docs
>  - remove GPIO initialization and update docs
> 
> v3:
>  - remove most of the memory barriers by using the non xxx_relaxed() api.
>  - remove RSS and WOL support.
>  - correct comments from physical address to dma address.
>  - rearrange structs to make them packed.
>  - replace polling loops with readl_poll_timeout().
>  - remove unnecessary wrapper functions from phy layer.
>  - add blank line before return statements.
>  - set to null clocks after clk_put().
>  - use module_platform_driver() and dma_set_mask_and_coherent()
>  - replace long hex bitmasks with BIT() macro.
> 
> v2:
>  - replace hw bit fields to macros with bitwise operations.
>  - change all iterators to unsized types (int)
>  - some minor code flow improvements.
>  - change return type to void for functions which return value is never
>    used.
>  - replace instance of xxxxl_relaxed() io followed by mb() with a
>    readl()/writel().
> 
> 
>  .../devicetree/bindings/net/qcom-emac.txt          |   63 +

Acked-by: Rob Herring <robh@kernel.org>

>  MAINTAINERS                                        |    6 +
>  drivers/net/ethernet/qualcomm/Kconfig              |   11 +
>  drivers/net/ethernet/qualcomm/Makefile             |    2 +
>  drivers/net/ethernet/qualcomm/emac/Makefile        |    7 +
>  drivers/net/ethernet/qualcomm/emac/emac-mac.c      | 1661 ++++++++++++++++++++
>  drivers/net/ethernet/qualcomm/emac/emac-mac.h      |  271 ++++
>  drivers/net/ethernet/qualcomm/emac/emac-phy.c      |  211 +++
>  drivers/net/ethernet/qualcomm/emac/emac-phy.h      |   32 +
>  drivers/net/ethernet/qualcomm/emac/emac-sgmii.c    |  700 +++++++++
>  drivers/net/ethernet/qualcomm/emac/emac-sgmii.h    |   24 +
>  drivers/net/ethernet/qualcomm/emac/emac.c          |  809 ++++++++++
>  drivers/net/ethernet/qualcomm/emac/emac.h          |  369 +++++
>  13 files changed, 4166 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/qcom-emac.txt
>  create mode 100644 drivers/net/ethernet/qualcomm/emac/Makefile
>  create mode 100644 drivers/net/ethernet/qualcomm/emac/emac-mac.c
>  create mode 100644 drivers/net/ethernet/qualcomm/emac/emac-mac.h
>  create mode 100644 drivers/net/ethernet/qualcomm/emac/emac-phy.c
>  create mode 100644 drivers/net/ethernet/qualcomm/emac/emac-phy.h
>  create mode 100644 drivers/net/ethernet/qualcomm/emac/emac-sgmii.c
>  create mode 100644 drivers/net/ethernet/qualcomm/emac/emac-sgmii.h
>  create mode 100644 drivers/net/ethernet/qualcomm/emac/emac.c
>  create mode 100644 drivers/net/ethernet/qualcomm/emac/emac.h
