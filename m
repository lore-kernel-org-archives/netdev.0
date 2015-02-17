From: Stathis Voukelatos <stathis.voukelatos-zgcZaY4qg+21Qrn1Bg8BZw@public.gmane.org>
Subject: [PATCH v2 0/3] net: Linn Ethernet Packet Sniffer driver
Date: Tue, 17 Feb 2015 14:03:30 +0000
Message-ID: <cover.1424181053.git.stathis.voukelatos@linn.co.uk>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <abrestic-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Stathis Voukelatos <stathis.voukelatos-zgcZaY4qg+21Qrn1Bg8BZw@public.gmane.org>
To: <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch adds support the Ethernet Packet Sniffer H/W module
developed by Linn Products Ltd and found in the IMG Pistachio SoC.
The module allows Ethernet packets to be parsed, matched against
a user-defined pattern and timestamped. It sits between a 100M
Ethernet MAC and PHY and is completely passive with respect to
Ethernet frames.

Matched packet bytes and timestamp values are returned through a
FIFO. Timestamps are provided to the module through an externally
generated Gray-encoded counter.

The command string for packet matching is stored in module RAM
and consists of a sequence of 16-bit entries. Each entry includes
an 8-bit command code and and 8-bit data value. Valid command
codes are:
0 - Don't care
1 - Match: packet data must match command string byte
2 - Copy: packet data will be copied to FIFO
3 - Match/Stamp: if packet data matches string byte, a timestamp
                 is copied into the FIFO
4 - Copy/Done: packet data will be copied into the FIFO.
               This command terminates the command string.

The driver consists of two modules:
- Core: it provides a common framework for managing backend packet
        sniffer implementations. Each backend channel is registered
        by the core as a netdev, which can be accessed from user
        space through a raw packet socket. 

- Ethernet Packet Sniffer backend: provides the driver for the
        Linn Ethernet Packet Sniffer H/W modules.

The split between a core and backend modules allows for other
implementations to be added in the future apart of the Ethernet
packet sniffer presented in this patch set.

Changes:
v2:
* Complete redesign of core framework to use netdev instead of 
the generic netlink framework
* Updated device tree binding
* A number of minor code improvements suggested by code review

Stathis Voukelatos (3):
  Ethernet packet sniffer: Device tree binding and vendor prefix
  Packet sniffer core framework
  Linn Ethernet packet sniffer driver

 .../bindings/net/linn-ether-packet-sniffer.txt     |  42 +++
 .../devicetree/bindings/vendor-prefixes.txt        |   1 +
 MAINTAINERS                                        |   6 +
 drivers/net/Kconfig                                |   2 +
 drivers/net/Makefile                               |   2 +
 drivers/net/pkt-sniffer/Kconfig                    |  19 +
 drivers/net/pkt-sniffer/Makefile                   |   7 +
 drivers/net/pkt-sniffer/backends/ether/channel.c   | 392 +++++++++++++++++++++
 drivers/net/pkt-sniffer/backends/ether/channel.h   |  81 +++++
 drivers/net/pkt-sniffer/backends/ether/hw.h        |  46 +++
 drivers/net/pkt-sniffer/backends/ether/platform.c  | 301 ++++++++++++++++
 drivers/net/pkt-sniffer/core/module.c              |  37 ++
 drivers/net/pkt-sniffer/core/netdev.c              | 254 +++++++++++++
 drivers/net/pkt-sniffer/core/snf_core.h            |  60 ++++
 include/uapi/linux/pkt_sniffer.h                   |  33 ++
 15 files changed, 1283 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/linn-ether-packet-sniffer.txt
 create mode 100644 drivers/net/pkt-sniffer/Kconfig
 create mode 100644 drivers/net/pkt-sniffer/Makefile
 create mode 100644 drivers/net/pkt-sniffer/backends/ether/channel.c
 create mode 100644 drivers/net/pkt-sniffer/backends/ether/channel.h
 create mode 100644 drivers/net/pkt-sniffer/backends/ether/hw.h
 create mode 100644 drivers/net/pkt-sniffer/backends/ether/platform.c
 create mode 100644 drivers/net/pkt-sniffer/core/module.c
 create mode 100644 drivers/net/pkt-sniffer/core/netdev.c
 create mode 100644 drivers/net/pkt-sniffer/core/snf_core.h
 create mode 100644 include/uapi/linux/pkt_sniffer.h

-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
