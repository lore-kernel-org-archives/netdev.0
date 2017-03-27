From: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH RFC v4 07/10] dt-bindings: net: add binding for QCA7000 UART
Date: Mon, 27 Mar 2017 15:30:01 -0500
Message-ID: <CAL_Jsq+gxS4u+b+C_eWeguFR0AFKuq8Hhe9Xo_5B_5w1hxvzEg@mail.gmail.com>
References: <1490621848-24828-1-git-send-email-stefan.wahren@i2se.com> <1490621848-24828-8-git-send-email-stefan.wahren@i2se.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
        Jiri Slaby <jslaby-IBi9RG/b67k@public.gmane.org>,
        Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
        Sebastian Reichel <sre-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-serial-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-serial-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Stefan Wahren <stefan.wahren-eS4NqCHxEME@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1490621848-24828-8-git-send-email-stefan.wahren-eS4NqCHxEME@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 27, 2017 at 8:37 AM, Stefan Wahren <stefan.wahren-eS4NqCHxEME@public.gmane.org> wrote:
> This is the serdev binding for the QCA7000 UART driver (Ethernet over UART).
>
> Signed-off-by: Stefan Wahren <stefan.wahren-eS4NqCHxEME@public.gmane.org>
> ---
>
> According to this binding are still some questions:
>
> Where should be the optional hardware flow control defined (at master or slave side)?

Probably should be in the slave side. We already have uart-has-rtscts
and rts/cts-gpios for the UART. Those mean we have RTS/CTS, but not
necessarily that we want to enable them.

In many cases, the driver may know what it needs.

> Is it okay to have two bindings (qca-qca7000-spi and qca-qca7000-uart) or should they be merged?

Are they mutually-exclusive or both are used at the same time? What
are the dependencies between the interfaces?

>
>
>  .../devicetree/bindings/net/qca-qca7000-uart.txt   | 31 ++++++++++++++++++++++
>  1 file changed, 31 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/qca-qca7000-uart.txt
>
> diff --git a/Documentation/devicetree/bindings/net/qca-qca7000-uart.txt b/Documentation/devicetree/bindings/net/qca-qca7000-uart.txt
> new file mode 100644
> index 0000000..f2e0450
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/qca-qca7000-uart.txt
> @@ -0,0 +1,31 @@
> +* Qualcomm QCA7000 (Ethernet over UART protocol)
> +
> +Note: This binding applies in case the QCA7000 is configured as a
> +UART slave device. It is possible to preconfigure the UART settings
> +of the QCA7000 firmware, which can't be changed during runtime.
> +
> +Required properties:
> +- compatible        : Should be "qca,qca7000-uart"
> +
> +Optional properties:
> +- local-mac-address : 6 bytes, Specifies MAC address

The description can be "see ./ethernet.txt"

> +- current-speed     : Specifies the serial device speed in
> +                     bits per second (default = 115200), which is
> +                     predefined by the QCA7000 firmware configuration

Add this to the slave binding doc with some caveats as to when this
should or should not be used as we discussed.

Rob
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
