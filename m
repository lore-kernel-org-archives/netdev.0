From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2 0/6] net: ethernet: bgmac: Add platform device support
Date: Fri, 8 Jul 2016 11:09:05 -0700
Message-ID: <577FEC41.4050101@gmail.com>
References: <1467932938-21819-1-git-send-email-jon.mason@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: zajec5@gmail.com, hauke@hauke-m.de,
	Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>, Ray Jui <rjui@broadcom.com>,
	Scott Branden <sbranden@broadcom.com>,
	bcm-kernel-feedback-list@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devicetree@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Jon Mason <jon.mason@broadcom.com>, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1467932938-21819-1-git-send-email-jon.mason@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/07/2016 04:08 PM, Jon Mason wrote:
> David Miller, Please consider including patches 1-5 in net-next
> 
> Florian Fainelli, Please consider including patches 6 & 7 in
>   devicetree/next

David should pick all 6 patches, including the binding documentation, as
this comes with the driver, I will take the DT patch (patch 7) through
Broadcom's arm-soc.

For this entire series, on BCM953012ER and BCM958625HR:

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
Tested-by: Florian Fainelli <f.fainelli@gmail.com>

> 
> Changes in v2:
> * Made device tree binding changes suggested by Sergei Shtylyov,
>   Ray Jui, Rob Herring, Florian Fainelli, and Arnd Bergmann
> * Removed devm_* error paths in the bgmac_platform.c suggested by
>   Florian Fainelli
> * Added Arnd Bergmann's Acked-by to the first 5 (there were changes
>   outlined in the bullets above, but I believe them to be minor enough
>   for him to not revoke his acks)
> 
> 
> This patch series adds support for other, non-bcma iProc SoC's to the
> bgmac driver.  This series only adds NSP support, but we are interested
> in adding support for the Cygnus and NS2 families (with more possible
> down the road).
> 
> To support non-bcma enabled SoCs, we need to add the standard device
> tree "platform device" support.  Unfortunately, this driver is very
> tighly coupled with the bcma bus and much unwinding is needed.  I tried
> to break this up into a number of patches to make it more obvious what
> was being done to add platform device support.  I was able to verify
> that the bcma code still works using a 53012K board (NS SoC), and that
> the platform code works using a 58625K board (NSP SoC).
> 
> Thanks,
> Jon
> 
> 
> Jon Mason (6):
>   net: ethernet: bgmac: change bgmac_* prints to dev_* prints
>   net: ethernet: bgmac: add dma_dev pointer
>   net: ethernet: bgmac: move BCMA MDIO Phy code into a separate file
>   net: ethernet: bgmac: convert to feature flags
>   net: ethernet: bgmac: Add platform device support
>   dt-bindings: net: bgmac: add bindings documentation for bgmac
> 
>  .../devicetree/bindings/net/brcm,amac.txt          |  24 +
>  .../devicetree/bindings/net/brcm,bgmac-nsp.txt     |  24 +
>  drivers/net/ethernet/broadcom/Kconfig              |  23 +-
>  drivers/net/ethernet/broadcom/Makefile             |   2 +
>  drivers/net/ethernet/broadcom/bgmac-bcma-mdio.c    | 266 +++++++++
>  drivers/net/ethernet/broadcom/bgmac-bcma.c         | 315 ++++++++++
>  drivers/net/ethernet/broadcom/bgmac-platform.c     | 189 ++++++
>  drivers/net/ethernet/broadcom/bgmac.c              | 658 +++++----------------
>  drivers/net/ethernet/broadcom/bgmac.h              | 112 +++-
>  9 files changed, 1097 insertions(+), 516 deletions(-)
>  create mode 100644 Documentation/devicetree/bindings/net/brcm,amac.txt
>  create mode 100644 Documentation/devicetree/bindings/net/brcm,bgmac-nsp.txt
>  create mode 100644 drivers/net/ethernet/broadcom/bgmac-bcma-mdio.c
>  create mode 100644 drivers/net/ethernet/broadcom/bgmac-bcma.c
>  create mode 100644 drivers/net/ethernet/broadcom/bgmac-platform.c
> 


-- 
Florian
