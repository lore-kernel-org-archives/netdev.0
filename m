From: Kumar Gala <galak@codeaurora.org>
Subject: Re: [PATCH 4/4] wl1251: spi: add device tree support
Date: Mon, 28 Oct 2013 01:37:34 -0500
Message-ID: <FF34C626-4A49-43B1-B0AD-DC6146ABBB11@codeaurora.org>
References: <1382890469-25286-1-git-send-email-sre@debian.org> <1382890469-25286-5-git-send-email-sre@debian.org>
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Sebastian Reichel <sre@ring0.de>, Luciano Coelho <luca@coelho.fi>,
	Rob Herring <rob.herring@calxeda.com>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Stephen Warren <swarren@wwwdotorg.org>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Rob Landley <rob@landley.net>,
	Tony Lindgren <tony@atomide.com>,
	Russell King <linux@arm.linux.org.uk>,
	"John W. Linville" <linville@tuxdriver.com>,
	Felipe Balbi <balbi@ti.com>,
	Sachin Kamat <sachin.kamat@linaro.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Bill Pemberton <wfp5p@virginia.edu>,
	devicetree@vger.kernel.org, linux-doc@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-omap@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Sebastian Reichel <sre@debian.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1382890469-25286-5-git-send-email-sre@debian.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Oct 27, 2013, at 11:14 AM, Sebastian Reichel wrote:

> Add device tree support for the spi variant of wl1251
> and document the binding.
> 
> Signed-off-by: Sebastian Reichel <sre@debian.org>
> ---
> .../devicetree/bindings/net/wireless/ti,wl1251.txt | 36 ++++++++++++++++++++++
> drivers/net/wireless/ti/wl1251/spi.c               | 23 ++++++++++----
> 2 files changed, 53 insertions(+), 6 deletions(-)
> create mode 100644 Documentation/devicetree/bindings/net/wireless/ti,wl1251.txt
> 
> diff --git a/Documentation/devicetree/bindings/net/wireless/ti,wl1251.txt b/Documentation/devicetree/bindings/net/wireless/ti,wl1251.txt
> new file mode 100644
> index 0000000..5f8a154
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/wireless/ti,wl1251.txt
> @@ -0,0 +1,36 @@
> +* Texas Instruments wl1251 controller
> +
> +The wl1251 chip can be connected via SPI or via SDIO. The linux
> +kernel currently only supports device tree for the SPI variant.
> +

>From the binding I have no idea what this chip actually does, also we don't normally reference linux kernel support in bindings specs (so please remove it).

However, what would expect the SDIO binding to look like?  Or more specifically, how would you distinguish the SPI vs SDIO binding/connection?  I'm wondering if the compatible should be something like "ti,wl1251-spi" and than the sdio can be "ti,wl1251-sdio"

> +Required properties:
> +- compatible : Should be "ti,wl1251"

reg is not listed as a required prop.

> +- interrupts : Should contain interrupt line
> +- interrupt-parent : Should be the phandle for the interrupt
> +  controller that services interrupts for this device
> +- vio-supply : phandle to regulator providing VIO
> +- power-gpio : GPIO connected to chip's PMEN pin

should be vendor prefixed: ti,power-gpio

> +- For additional required properties on SPI, please consult
> +  Documentation/devicetree/bindings/spi/spi-bus.txt
> +
> +Optional properties:
> +- ti,use-eeprom : If found, configuration will be loaded from eeprom.

can you be a bit more specific on what cfg will be loaded.  Also, is this property a boolean, if so how do I know which eeprom the cfg is loaded from (is it one that is directly connected to the wl1251?

> +
> +Examples:
> +
> +&spi1 {
> +	wl1251_spi@0 {
> +		compatible = "ti,wl1251";
> +
> +		reg = <0>;
> +		spi-max-frequency = <48000000>;
> +		spi-cpol;
> +		spi-cpha;
> +
> +		interrupt-parent = <&gpio2>;
> +		interrupts = <10 IRQ_TYPE_NONE>; /* gpio line 42 */
> +
> +		vio-supply = <&vio>;
> +		power-gpio = <&gpio3 23 GPIO_ACTIVE_HIGH>; /* 87 */
> +	};
> +};

-- 
Employee of Qualcomm Innovation Center, Inc.
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum, hosted by The Linux Foundation
