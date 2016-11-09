From: Rob Herring <robh@kernel.org>
Subject: Re: [RFC PATCH v2 1/5] net: mdio-mux-mmioreg: Add support for 16bit
 and 32bit register sizes
Date: Wed, 9 Nov 2016 12:26:10 -0600
Message-ID: <20161109182610.thzm5bxfwusi4kjk@rob-hp-laptop>
References: <1477932987-27871-1-git-send-email-narmstrong@baylibre.com>
 <1477932987-27871-2-git-send-email-narmstrong@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: f.fainelli@gmail.com, khilman@baylibre.com, carlo@caione.org,
        andrew@lunn.ch, netdev@vger.kernel.org,
        linux-amlogic@lists.infradead.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        devicetree@vger.kernel.org
To: Neil Armstrong <narmstrong@baylibre.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1477932987-27871-2-git-send-email-narmstrong@baylibre.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 31, 2016 at 05:56:23PM +0100, Neil Armstrong wrote:
> In order to support PHY switching on Amlogic GXL SoCs, add support for
> 16bit and 32bit registers sizes.
> 
> Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
> ---
>  .../devicetree/bindings/net/mdio-mux-mmioreg.txt   |  4 +-
>  drivers/net/phy/mdio-mux-mmioreg.c                 | 60 +++++++++++++++++-----
>  2 files changed, 49 insertions(+), 15 deletions(-)
> 
> diff --git a/Documentation/devicetree/bindings/net/mdio-mux-mmioreg.txt b/Documentation/devicetree/bindings/net/mdio-mux-mmioreg.txt
> index 8516929..065e8bd 100644
> --- a/Documentation/devicetree/bindings/net/mdio-mux-mmioreg.txt
> +++ b/Documentation/devicetree/bindings/net/mdio-mux-mmioreg.txt
> @@ -3,7 +3,7 @@ Properties for an MDIO bus multiplexer controlled by a memory-mapped device
>  This is a special case of a MDIO bus multiplexer.  A memory-mapped device,
>  like an FPGA, is used to control which child bus is connected.  The mdio-mux
>  node must be a child of the memory-mapped device.  The driver currently only

As you're touching this sentence, this describes the binding, not a 
driver. With that,

Acked-by: Rob Herring <robh@kernel.org>

> -supports devices with eight-bit registers.
> +supports devices with 8, 16 or 32-bit registers.
>  
>  Required properties in addition to the generic multiplexer properties:
>  
> @@ -11,7 +11,7 @@ Required properties in addition to the generic multiplexer properties:
>  
>  - reg : integer, contains the offset of the register that controls the bus
>  	multiplexer.  The size field in the 'reg' property is the size of
> -	register, and must therefore be 1.
> +	register, and must therefore be 1, 2, or 4.
>  
>  - mux-mask : integer, contains an eight-bit mask that specifies which
>  	bits in the register control the actual bus multiplexer.  The
