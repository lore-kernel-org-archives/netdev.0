From: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 08/10] mtd: flash-sam: Bindings for Juniper's SAM FPGA
 flash
Date: Mon, 10 Oct 2016 15:07:04 -0500
Message-ID: <20161010200704.GA28870@rob-hp-laptop>
References: <1475853518-22264-1-git-send-email-pantelis.antoniou@konsulko.com>
 <1475853518-22264-9-git-send-email-pantelis.antoniou@konsulko.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Lee Jones <lee.jones-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        Alexandre Courbot <gnurou-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Frank Rowand <frowand.list-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Wolfram Sang <wsa-z923LK4zBo2bacvFa/9K2g@public.gmane.org>,
        David Woodhouse <dwmw2-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
        Brian Norris <computersforpeace-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Wim Van Sebroeck <wim-IQzOog9fTRqzQB+pC5nmwQ@public.gmane.org>,
        Peter Rosin <peda-koto5C5qi+TLoDKTGw+V6w@public.gmane.org>,
        Debjit Ghosh <dghosh-3r7Miqu9kMnR7s880joybQ@public.gmane.org>,
        Georgi Vlaev <gvlaev-3r7Miqu9kMnR7s880joybQ@public.gmane.org>,
        Guenter Roeck <linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>,
        Maryam Seraj <mseraj-3r7Miqu9kMnR7s880joybQ@public.gmane.org>, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-gpio-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mtd-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        linux-watchdog-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Pantelis Antoniou <pantelis.antoniou-OWPKS81ov/FWk0Htik3J/w@public.gmane.org>
Return-path: <linux-watchdog-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1475853518-22264-9-git-send-email-pantelis.antoniou-OWPKS81ov/FWk0Htik3J/w@public.gmane.org>
Sender: linux-watchdog-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

gOn Fri, Oct 07, 2016 at 06:18:36PM +0300, Pantelis Antoniou wrote:
> From: Georgi Vlaev <gvlaev-3r7Miqu9kMnR7s880joybQ@public.gmane.org>
> 
> Add binding document for Junipers Flash IP block present
> in the SAM FPGA on PTX series of routers.
> 
> Signed-off-by: Georgi Vlaev <gvlaev-3r7Miqu9kMnR7s880joybQ@public.gmane.org>
> [Ported from Juniper kernel]
> Signed-off-by: Pantelis Antoniou <pantelis.antoniou-OWPKS81ov/FWk0Htik3J/w@public.gmane.org>
> ---
>  .../devicetree/bindings/mtd/flash-sam.txt          | 31 ++++++++++++++++++++++
>  1 file changed, 31 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/mtd/flash-sam.txt
> 
> diff --git a/Documentation/devicetree/bindings/mtd/flash-sam.txt b/Documentation/devicetree/bindings/mtd/flash-sam.txt
> new file mode 100644
> index 0000000..bdf1d78
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/mtd/flash-sam.txt
> @@ -0,0 +1,31 @@
> +Flash device on a Juniper SAM FPGA
> +
> +These flash chips are found in the PTX series of Juniper routers.
> +
> +They are regular CFI compatible (Intel or AMD extended) flash chips with
> +some special write protect/VPP bits that can be controlled by the machine's
> +system controller.

And where's the description of the sys ctrlr?

> +
> +Required properties:
> +- compatible : must be "jnx,flash-sam"
> +
> +Optional properties:
> +- reg : memory address for the flash chip, note that this is not
> +required since usually the device is a subdevice of the SAM MFD
> +driver which fills in the register fields.
> +
> +For the rest of the properties, see mtd-physmap.txt.
> +
> +The device tree may optionally contain sub-nodes describing partitions of the
> +address space. See partition.txt for more detail.
> +
> +Example:
> +
> +flash_sam {
> +	compatible = "jnx,flash-sam";
> +	partition@0 {

This should have a heirarchy of a controller node, a flash child node, 
partitions child node, and partition child nodes.

> +		reg = <0x0 0x400000>;
> +		label = "pic0-golden";
> +		read-only;
> +	};
> +};
> -- 
> 1.9.1
> 
--
To unsubscribe from this list: send the line "unsubscribe linux-watchdog" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
