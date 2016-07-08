From: Jon Mason <jon.mason@broadcom.com>
Subject: Re: [PATCH v2 0/6] net: ethernet: bgmac: Add platform device support
Date: Fri, 8 Jul 2016 11:52:42 -0400
Message-ID: <CAC3K-4r6wsL++uO8KZWYf75KNCrEGi3VB9vbWbWT_yVUP7TgWg@mail.gmail.com>
References: <1467932938-21819-1-git-send-email-jon.mason@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland@arm.com>, devicetree@vger.kernel.org,
 Scott Branden <sbranden@broadcom.com>, Pawel Moll <pawel.moll@arm.com>,
 Ian Campbell <ijc+devicetree@hellion.org.uk>,
 Hauke Mehrtens <hauke@hauke-m.de>,
 =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>,
 linux-kernel@vger.kernel.org, Ray Jui <rjui@broadcom.com>,
 Rob Herring <robh+dt@kernel.org>,
 BCM Kernel Feedback <bcm-kernel-feedback-list@broadcom.com>,
 Kumar Gala <galak@codeaurora.org>, netdev@vger.kernel.org,
 linux-arm-kernel <linux-arm-kernel@lists.infradead.org>
To: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1467932938-21819-1-git-send-email-jon.mason@broadcom.com>
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

On Thu, Jul 7, 2016 at 7:08 PM, Jon Mason <jon.mason@broadcom.com> wrote:
> David Miller, Please consider including patches 1-5 in net-next
>
> Florian Fainelli, Please consider including patches 6 & 7 in
>   devicetree/next

Oops.  I didn't send out the 7th patch in this series.  Sending out
shortly as 7/7.

Thanks,
Jon

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
> --
> 1.9.1
>
