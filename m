From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH 1/2] Documentation: devicetree: Add bindings info for
 rfkill-regulator
Date: Wed, 9 Nov 2016 12:26:12 -0600
Message-ID: <20161109182612.i4rnsdxulk5ghemz@rob-hp-laptop>
References: <20161101105840.24313-1-paul@crapouillou.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes@sipsolutions.net>,
        "David S . Miller" <davem@davemloft.net>,
        Mark Rutland <mark.rutland@arm.com>, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-wireless@vger.kernel.org,
        Maarten ter Huurne <maarten@treewalker.org>
To: Paul Cercueil <paul@crapouillou.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161101105840.24313-1-paul@crapouillou.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 01, 2016 at 11:58:39AM +0100, Paul Cercueil wrote:
> This document gives information about how to write a devicetree
> node that corresponds to the rfkill-regulator driver.
> 
> Signed-off-by: Paul Cercueil <paul@crapouillou.net>
> ---
>  .../devicetree/bindings/net/rfkill-regulator.txt       | 18 ++++++++++++++++++
>  1 file changed, 18 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/rfkill-regulator.txt
> 
> diff --git a/Documentation/devicetree/bindings/net/rfkill-regulator.txt b/Documentation/devicetree/bindings/net/rfkill-regulator.txt
> new file mode 100644
> index 0000000..aac2fe1
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/rfkill-regulator.txt
> @@ -0,0 +1,18 @@
> +Device tree bindings for the rfkill-regulator driver
> +
> +Required properties:
> +  - compatible:	should be "rfkill-regulator"
> +  - rfkill-name:	the name of this rfkill device
> +  - rfkill-type:	the type of this rfkill device;
> +			must correspond to a valid rfkill_type from <uapi/linux/rfkill.h>
> +  - vrfkill-supply:	phandle to a regulator

My understanding is it is generally felt that using the regulator enable 
GPIO commonly found on WiFi chips for rfkill is an abuse of rfkill as it 
is more that just an RF disable. From a DT standpoint, this seems like 
creating a binding for what a Linux driver wants. Instead, I think this 
should be either a GPIO or GPIO regulator and the driver for the WiFi 
chip should decide whether or not to register that as an rfkill driver.

Rob
