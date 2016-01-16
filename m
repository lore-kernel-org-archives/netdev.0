From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 1/2] ne: DeviceTree support.
Date: Sat, 16 Jan 2016 18:22:26 +0100
Message-ID: <20160116172226.GB9880@lunn.ch>
References: <1452874786-21202-1-git-send-email-ysato@users.sourceforge.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Yoshinori Sato <ysato@users.sourceforge.jp>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1452874786-21202-1-git-send-email-ysato@users.sourceforge.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 16, 2016 at 01:19:45AM +0900, Yoshinori Sato wrote:
> Add basic device tree support.
> 
> Signed-off-by: Yoshinori Sato <ysato@users.sourceforge.jp>
> ---
>  Documentation/devicetree/bindings/net/ne2000.txt | 17 +++++++++++++++++
>  drivers/net/ethernet/8390/ne.c                   | 20 +++++++++++++++++++-
>  2 files changed, 36 insertions(+), 1 deletion(-)
>  create mode 100644 Documentation/devicetree/bindings/net/ne2000.txt
> 
> diff --git a/Documentation/devicetree/bindings/net/ne2000.txt b/Documentation/devicetree/bindings/net/ne2000.txt
> new file mode 100644
> index 0000000..8b0dfbf
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/ne2000.txt
> @@ -0,0 +1,17 @@
> +NE2000 compatible network controller
> +
> +Required properties:
> +- compatible: "national,ne2000"
> +- reg: base address and length of NE2000.
> +- interrupts: interrupt specifier for the sole interrupt.
> +- national,dcr: DCR setting value.

You say here that national,dcr is required, yet the code to read it is
not returning an error if it is missing.

Also, what is DCR? 

> +
> +Example
> +
> +	ne2000: ethernet@200000 {
> +		compatible = "national,ne2000";
> +		reg = <0x200000 32>;
> +		interrupts = <17 0>;
> +		national,dcr = <0x48>;
> +	};
> +
> diff --git a/drivers/net/ethernet/8390/ne.c b/drivers/net/ethernet/8390/ne.c
> index c063b41..a9dde5b 100644
> --- a/drivers/net/ethernet/8390/ne.c
> +++ b/drivers/net/ethernet/8390/ne.c
> @@ -52,6 +52,7 @@ static const char version2[] =
>  #include <linux/etherdevice.h>
>  #include <linux/jiffies.h>
>  #include <linux/platform_device.h>
> +#include <linux/of.h>
>  
>  #include <asm/io.h>
>  
> @@ -72,6 +73,7 @@ static int io[MAX_NE_CARDS];
>  static int irq[MAX_NE_CARDS];
>  static int bad[MAX_NE_CARDS];
>  static u32 ne_msg_enable;
> +static unsigned int of_dcr_val;

So there is a single DCR value, for all instances of the device?
The last device to probe wins?
  
  Andrew
