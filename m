From: Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] net: Linn Ethernet Packet Sniffer driver
Date: Fri, 23 Jan 2015 12:20:08 +0100
Message-ID: <54C22E68.1080601@redhat.com>
References: <1422007621-13567-1-git-send-email-stathis.voukelatos@linn.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Stathis Voukelatos <stathis.voukelatos-zgcZaY4qg+21Qrn1Bg8BZw@public.gmane.org>,
	abrestic-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org
To: Stathis Voukelatos <stathisv70-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1422007621-13567-1-git-send-email-stathis.voukelatos-zgcZaY4qg+21Qrn1Bg8BZw@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 01/23/2015 11:07 AM, Stathis Voukelatos wrote:
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
>                   is copied into the FIFO
> 4 - Copy/Done: packet data will be copied into the FIFO.
>                 This command terminates the command string.
>
> The driver consists of two modules:
> - Core: it provides an API to user space using the Generic Netlink
>          framework. Specific backend implementations, like the
>          Ethernet Packet Sniffer, register one or more channels
>          with the Core. For each channel a Genl family is created.
>          User space can access a channel by sending Genl messages
>          to the Genl family associated with the channel. Packet
>          matching events are multicast.
>
> - Ethernet Packet Sniffer backend: provides the driver for the
>          Linn Ethernet Packet Sniffer H/W modules.
>
> The split between a core and backend modules allows software-only
> implementations to be added for platforms where no H/W support
> is available.
>
> Based on 3.19-rc5
>
> Signed-off-by: Stathis Voukelatos <stathis.voukelatos-zgcZaY4qg+21Qrn1Bg8BZw@public.gmane.org>

Please have a look at packet sockets, they offer already all the
functionality (if not more) your driver interface to the user space
resembles, are transparent to the underlying hardware, and easily
can cope with 100Mbit.

If I understand this correctly, you are effectively introducing a
parallel API *next* to packet sockets to user space that we have to
maintain forever ...

Thanks !
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
