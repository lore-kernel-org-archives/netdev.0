From: Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>
Subject: Re: [PATCH] net: Linn Ethernet Packet Sniffer driver
Date: Fri, 23 Jan 2015 10:51:14 +0000
Message-ID: <20150123105114.GB23493@leverpostej>
References: <1422007621-13567-1-git-send-email-stathis.voukelatos@linn.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Stathis Voukelatos <stathis.voukelatos-zgcZaY4qg+21Qrn1Bg8BZw@public.gmane.org>,
	"abrestic-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org" <abrestic-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
To: Stathis Voukelatos <stathisv70-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1422007621-13567-1-git-send-email-stathis.voukelatos-zgcZaY4qg+21Qrn1Bg8BZw@public.gmane.org>
Content-Language: en-US
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 23, 2015 at 10:07:01AM +0000, Stathis Voukelatos wrote:
> This patch adds support the Ethernet Packet Sniffer H/W module
> developed by Linn Products Ltd and found in the IMG Pistachio SoC.
> The module allows Ethernet packets to be parsed, matched against
> a user-defined pattern and timestamped. It sits between a 100M
> Ethernet MAC and PHY and is completely passive with respect to
> Ethernet frames.
>
> Matched packet bytes and timestamp values are returned through a
> FIFO. Timestamps are provided to the module through an externally
> generated Gray-encoded counter.
>
> The command pattern for packet matching is stored in module RAM
> and consists of a sequence of 16-bit entries. Each entry includes
> an 8-bit command code and and 8-bit data value. Valid command
> codes are:
> 0 - Don't care
> 1 - Match: packet data must match command string byte
> 2 - Copy: packet data will be copied to FIFO
> 3 - Match/Stamp: if packet data matches string byte, a timestamp
>                  is copied into the FIFO
> 4 - Copy/Done: packet data will be copied into the FIFO.
>                This command terminates the command string.
>
> The driver consists of two modules:
> - Core: it provides an API to user space using the Generic Netlink
>         framework. Specific backend implementations, like the
>         Ethernet Packet Sniffer, register one or more channels
>         with the Core. For each channel a Genl family is created.
>         User space can access a channel by sending Genl messages
>         to the Genl family associated with the channel. Packet
>         matching events are multicast.
>
> - Ethernet Packet Sniffer backend: provides the driver for the
>         Linn Ethernet Packet Sniffer H/W modules.

It sounds like the framework and particular driver need to be split into
separate patches.

Also, please split the binding patch as per
Documentation/devicetree/bindings/submitting-patches.txt.

>
> The split between a core and backend modules allows software-only
> implementations to be added for platforms where no H/W support
> is available.
>
> Based on 3.19-rc5
>
> Signed-off-by: Stathis Voukelatos <stathis.voukelatos-zgcZaY4qg+21Qrn1Bg8BZw@public.gmane.org>
> ---
>  .../bindings/net/linn-ether-packet-sniffer.txt     |  27 ++
>  .../devicetree/bindings/vendor-prefixes.txt        |   1 +
>  MAINTAINERS                                        |   7 +
>  drivers/net/Kconfig                                |   2 +
>  drivers/net/Makefile                               |   1 +
>  drivers/net/pkt-sniffer/Kconfig                    |  23 ++
>  drivers/net/pkt-sniffer/Makefile                   |   8 +
>  drivers/net/pkt-sniffer/backends/ether/channel.c   | 366 ++++++++++++++++++
>  drivers/net/pkt-sniffer/backends/ether/channel.h   |  76 ++++
>  drivers/net/pkt-sniffer/backends/ether/hw.h        |  46 +++
>  drivers/net/pkt-sniffer/backends/ether/platform.c  | 231 +++++++++++
>  drivers/net/pkt-sniffer/core/dev_table.c           | 124 ++++++
>  drivers/net/pkt-sniffer/core/module.c              |  37 ++
>  drivers/net/pkt-sniffer/core/nl.c                  | 427 +++++++++++++++++++++
>  drivers/net/pkt-sniffer/core/nl.h                  |  34 ++
>  drivers/net/pkt-sniffer/core/snf_core.h            |  64 +++
>  include/linux/pkt_sniffer.h                        |  89 +++++
>  17 files changed, 1563 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/linn-ether-packet-sniffer.txt
>  create mode 100644 drivers/net/pkt-sniffer/Kconfig
>  create mode 100644 drivers/net/pkt-sniffer/Makefile
>  create mode 100644 drivers/net/pkt-sniffer/backends/ether/channel.c
>  create mode 100644 drivers/net/pkt-sniffer/backends/ether/channel.h
>  create mode 100644 drivers/net/pkt-sniffer/backends/ether/hw.h
>  create mode 100644 drivers/net/pkt-sniffer/backends/ether/platform.c
>  create mode 100644 drivers/net/pkt-sniffer/core/dev_table.c
>  create mode 100644 drivers/net/pkt-sniffer/core/module.c
>  create mode 100644 drivers/net/pkt-sniffer/core/nl.c
>  create mode 100644 drivers/net/pkt-sniffer/core/nl.h
>  create mode 100644 drivers/net/pkt-sniffer/core/snf_core.h
>  create mode 100644 include/linux/pkt_sniffer.h
>
> diff --git a/Documentation/devicetree/bindings/net/linn-ether-packet-sniffer.txt b/Documentation/devicetree/bindings/net/linn-ether-packet-sniffer.txt
> new file mode 100644
> index 0000000..6b6e105
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/linn-ether-packet-sniffer.txt
> @@ -0,0 +1,27 @@
> +* Linn Products Ethernet Packet Sniffer
> +
> +Required properties:
> +- compatible : must be "linn,eth-sniffer"
> +- reg : physical addresses and sizes of registers. Must contain 3 entries:
> +          first entry: registers memory space
> +          second entry: TX command memory
> +          third entry: RX command memory

Just to check: are those memories are part of the packet sniffer device,
or are carveouts from other memory?

> +- reg-names : must contain the following 3 entries:
> +                  "regs", "tx-ram", "rx-ram"

If you use reg-names, please define reg in terms of reg-names. It's a
little pointless to have redundant name and index requirements.

> +- interrupts : sniffer interrupt specifier
> +- clocks : specify the system clock for the peripheral
> +- clock-names : must contain the "sys" entry

Likewise with clocks and clock-names.

> +- fifo-block-words : number of words in one data FIFO entry
> +
> +Example:
> +
> +sniffer@1814a000 {
> +        compatible = "linn,eth-sniffer";
> +        reg = <0x1814a000 0x100>, <0x1814a400 0x400>, <0x1814a800 0x400>;
> +        reg-names = "regs", "tx-ram", "rx-ram";
> +        interrupts = <GIC_SHARED 58 IRQ_TYPE_LEVEL_HIGH>;
> +        interrupt-names = "eth-sniffer-irq";
> +        clocks = <&system_clk>;
> +        clock-names = "sys";
> +        fifo-block-words = <4>;
> +    };

Surely the relationship between the sniffer, MAC, and PHY should be
described, so we know which interface the sniffer is related to?

> diff --git a/Documentation/devicetree/bindings/vendor-prefixes.txt b/Documentation/devicetree/bindings/vendor-prefixes.txt
> index b1df0ad..2c96f35 100644
> --- a/Documentation/devicetree/bindings/vendor-prefixes.txt
> +++ b/Documentation/devicetree/bindings/vendor-prefixes.txt
> @@ -90,6 +90,7 @@ lacie LaCie
>  lantiq Lantiq Semiconductor
>  lenovo Lenovo Group Ltd.
>  lg     LG Corporation
> +linn   Linn Products Ltd.
>  linux  Linux-specific binding
>  lsi    LSI Corp. (LSI Logic)
>  lltc   Linear Technology Corporation

This addition looks fine to me.

Thanks,
Mark.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
