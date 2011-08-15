From: Jamie Iles <jamie@jamieiles.com>
Subject: Re: [RFC PATCH v2] net: dm9000: add support for device tree probing
Date: Mon, 15 Aug 2011 15:21:16 +0100
Message-ID: <20110815142116.GG2636@pulham.picochip.com>
References: <1313343252-19634-1-git-send-email-daniel.morsing@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: devicetree-discuss@lists.ozlabs.org, netdev@vger.kernel.org,
	Mark Brown <broonie@opensource.wolfsonmicro.com>,
	Ben Dooks <ben-linux@fluff.org>,
	"David S. Miller" <davem@davemloft.net>
To: Daniel Morsing <daniel.morsing@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:33673 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753020Ab1HOOVU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2011 10:21:20 -0400
Received: by wyg24 with SMTP id 24so3517992wyg.19
        for <netdev@vger.kernel.org>; Mon, 15 Aug 2011 07:21:19 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1313343252-19634-1-git-send-email-daniel.morsing@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Daniel,

On Sun, Aug 14, 2011 at 07:34:12PM +0200, Daniel Morsing wrote:
> This patch adds support for probing the dm9000 driver through device
> trees.
> 
> The patch works by supplying its own platform_data struct when probed
> via device tree. This allows us to rely on the existing options parsing
> in the driver and avoid ifdeffery in the probe function.
> 
> Signed-off-by: Daniel Morsing <daniel.morsing@gmail.com>
> ---
> Currently there are no users of this functionality, but once support for
> DT on OMAP3 matures, I plan to migrate the devkit8000 board to DT.
> 
>  Changes since v1:
> 	- Changed the binding with input from Grant Likely.
> 	- Make explicit what the bindings do instead of refering
> 	  to linux specific flags.
> 	- Length check the mac address read so we don't copy random data.
> 	- simplify parsing of the device tree.
> 	- Add relevant driver maintainers to CC (sorry about that)
> 
>  Documentation/devicetree/bindings/net/dm9000.txt |   42 +++++++++++
>  drivers/net/dm9000.c                             |   83 +++++++++++++++++++++-
>  2 files changed, 122 insertions(+), 3 deletions(-)
>  create mode 100644 Documentation/devicetree/bindings/net/dm9000.txt
> 
> diff --git a/Documentation/devicetree/bindings/net/dm9000.txt b/Documentation/devicetree/bindings/net/dm9000.txt
> new file mode 100644
> index 0000000..cbbdb3d
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/dm9000.txt
> @@ -0,0 +1,42 @@
> +Davicom DM9000 ethernet controller
> +
> +Required properties:
> +
> + - compatible : Should be "davicom,dm9000"
> +
> + - interrupts : Interrupt controller specific encoding, which specifies 1
> +   or 2 interrupts. The first interrupt is for rx/tx and is required by the
> +   driver to function. The second interrupt is for wake on lan support
> +   and is optional.
> +
> + - reg : 2 Physical address specifiers, where the first specifies the address
> +   register of device, and the second specifies the data register of the device
> +
> +Optional properties:
> +
> + - local-mac-address : Binary data specifying a mac address override
> +
> + - reg-io-width : one cell specifying the width of IO operations in bits.
> +   valid values are 8, 16, and 32. If this property is not specified, or has
> +   an invalid value, the driver will default to 32 bits.

Minor nit, but rightly or wrongly, the of-serial binding that uses 
reg-io-width specifies this in bytes and it would be nice to be 
consistent here.

Jamie
