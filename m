From: Michael Heimpold <mhei-Z/Lg1yOAjpkb1SvskN2V4Q@public.gmane.org>
Subject: Re: [PATCH v5 15/17] dt-bindings: qca7000: append UART interface to binding
Date: Thu, 11 May 2017 21:12:22 +0200
Message-ID: <1702237.66ccflAQAJ@kerker>
References: <1494406408-31760-1-git-send-email-stefan.wahren@i2se.com> <1494406408-31760-16-git-send-email-stefan.wahren@i2se.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Stefan Wahren <stefan.wahren-eS4NqCHxEME@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
        Jiri Slaby <jslaby-IBi9RG/b67k@public.gmane.org>, linux-serial-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1494406408-31760-16-git-send-email-stefan.wahren-eS4NqCHxEME@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

Am Mittwoch, 10. Mai 2017, 10:53:26 CEST schrieb Stefan Wahren:
> This merges the serdev binding for the QCA7000 UART driver (Ethernet over
> UART) into the existing document.
> 
> Signed-off-by: Stefan Wahren <stefan.wahren-eS4NqCHxEME@public.gmane.org>
> ---
>  .../devicetree/bindings/net/qca-qca7000.txt        | 32
> ++++++++++++++++++++++ 1 file changed, 32 insertions(+)
> 
> diff --git a/Documentation/devicetree/bindings/net/qca-qca7000.txt
> b/Documentation/devicetree/bindings/net/qca-qca7000.txt index
> a37f656..08364c3 100644
> --- a/Documentation/devicetree/bindings/net/qca-qca7000.txt
> +++ b/Documentation/devicetree/bindings/net/qca-qca7000.txt
> @@ -54,3 +54,35 @@ ssp2: spi@80014000 {
>  		local-mac-address = [ A0 B0 C0 D0 E0 F0 ];
>  	};
>  };
> +
> +(b) Ethernet over UART
> +
> +In order to use the QCA7000 as UART slave it must be defined as a child of
> a +UART master in the device tree. It is possible to preconfigure the UART
> +settings of the QCA7000 firmware, but it's not possible to change them
> during +runtime.
> +
> +Required properties:
> +- compatible        : Should be "qca,qca7000-uart"

I already discussed this with Stefan off-list a little bit, but I would like
to bring this to a broader audience: I'm not sure whether the compatible 
should contain the "-uart" suffix, because the hardware chip is the very same
QCA7000 chip which can also be used with SPI protocol.
The only difference is the loaded firmware within the chip which can either
speak SPI or UART protocol (but not both at the same time - due to shared 
pins). So the hardware design decides which interface type is used.

At the moment, this patch series adds a dedicated driver for the UART 
protocol, in parallel to the existing SPI driver. So a different compatible
string is needed here to match against the new driver.

An alternative approach would be to re-use the existing compatible string
"qca,qca7000" for both, the SPI and UART protocol, because a "smarter" 
(combined) driver would detect which protocol to use. For example the driver 
could check for spi-cpha and/or spi-cpol which are required for SPI protocol: 
if these exists the driver could assume that SPI must be used, if both are 
missing then UART protocol should be used.
(This way it would not be necessary to check whether the node is a child of
a SPI or UART master node - but maybe this is even easier - I don't know)

Or in shorter words: my concern is that while "qca7000-uart" describes the 
hardware, it's too closely coupled to the driver implementation. Having
some feedback of the experts would be nice :-)

Thanks,
Michael

> +
> +Optional properties:
> +- local-mac-address : see ./ethernet.txt
> +- current-speed     : current baud rate of QCA7000 which defaults to 115200
> +		      if absent, see also ../serial/slave-device.txt
> +
> +UART Example:
> +
> +/* Freescale i.MX28 UART */
> +auart0: serial@8006a000 {
> +	compatible = "fsl,imx28-auart", "fsl,imx23-auart";
> +	reg = <0x8006a000 0x2000>;
> +	pinctrl-names = "default";
> +	pinctrl-0 = <&auart0_2pins_a>;
> +	status = "okay";
> +
> +	qca7000: ethernet {
> +		compatible = "qca,qca7000-uart";
> +		local-mac-address = [ A0 B0 C0 D0 E0 F0 ];
> +		current-speed = <38400>;
> +	};
> +};


--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
