From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH RFC 1/2] Documentation: add Device tree bindings for
 QCA7000
Date: Tue, 29 Apr 2014 15:36:38 -0700
Message-ID: <20140429223638.GB2382@flaeskesteg>
References: <1398707697-43785-1-git-send-email-stefan.wahren@i2se.com>
 <1398707697-43785-2-git-send-email-stefan.wahren@i2se.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"robh+dt@kernel.org" <robh+dt@kernel.org>,
	"pawel.moll@arm.org" <pawel.moll@arm.org>,
	"mark.rutland@arm.org" <mark.rutland@arm.org>,
	"ijc+devicetree@hellion.org.uk" <ijc+devicetree@hellion.org.uk>,
	"galak@codeaurora.org" <galak@codeaurora.org>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: Stefan Wahren <stefan.wahren@i2se.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cam-admin0.cambridge.arm.com ([217.140.96.50]:64188 "EHLO
	cam-admin0.cambridge.arm.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S965473AbaD2WhC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2014 18:37:02 -0400
Content-Disposition: inline
In-Reply-To: <1398707697-43785-2-git-send-email-stefan.wahren@i2se.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 28, 2014 at 06:54:56PM +0100, Stefan Wahren wrote:
> This patch adds the Device tree bindings for the Ethernet over SPI
> protocol driver of the Qualcomm QCA7000 HomePlug GreenPHY.
> 
> Signed-off-by: Stefan Wahren <stefan.wahren@i2se.com>
> ---
>  .../devicetree/bindings/net/qca-qca7000-spi.txt    |   51 ++++++++++++++++++++
>  1 file changed, 51 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/qca-qca7000-spi.txt
> 
> diff --git a/Documentation/devicetree/bindings/net/qca-qca7000-spi.txt b/Documentation/devicetree/bindings/net/qca-qca7000-spi.txt
> new file mode 100644
> index 0000000..132c10f
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/qca-qca7000-spi.txt
> @@ -0,0 +1,51 @@
> +* Qualcomm QCA7000 (Ethernet over SPI protocol)
> +
> +Note: The QCA7000 is useable as a SPI device. In this case it must be defined
> +as a child of a spi master in the device tree.
> +
> +Required properties:
> +- compatible : Should be "qca,qca7000"
> +- reg : Should specify the SPI chip select
> +- intr-gpios : Should specify the GPIO for SPI interrupt

As Arnd mentioned, this should be described as an interrupt if it's an
interrupt from the point of view of the QCA7000.

> +- spi-cpha : Must be set
> +- spi-cpol: Must be set
> +
> +Optional properties:
> +- spi-max-frequency : Maximum frequency of the SPI bus the chip can operate at.
> +  Numbers smaller than 1000000 or greater than 16000000 are invalid. Missing
> +  the property will set the SPI frequency to 8000000 Hertz.
> +- local-mac-address: 6 bytes, mac address
> +- qca,legacy-mode : Should specify the data transfer mode of the QCA7000
> +  (0 = burst mode, 1 = legacy mode). Missing the property will use the
> +  burst mode.

This sounds like it could be a boolean property (one with no value, like
cpi-cpha). When is this necessary?

> +- linux,burst-length : Number of data bytes per burst. Numbers smaller than 1
> +  or greater than 5000 are invalid. Missing the property will set the
> +  burst length to 5000 bytes. This property has only an effect in burst mode.

When is this needed?

> +- linux,pluggable-connection : Should be set to skip signature check while
> +  probing. This property is useful if the SPI master and QCA7000 are not on the
> +  same board.

This does not sounds like it belongs in the DT, as it's strongly tied to the
implementation of the driver. Why is this necessary?

Cheers,
Mark.
