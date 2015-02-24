From: Stathis Voukelatos <stathis.voukelatos@linn.co.uk>
Subject: [PATCH net-next v4 0/3] Linn Ethernet Packet Sniffer driver
Date: Tue, 24 Feb 2015 16:48:08 +0000
Message-ID: <cover.1424796018.git.stathis.voukelatos@linn.co.uk>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Stathis Voukelatos <stathis.voukelatos@linn.co.uk>
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<devicetree@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds support for the Ethernet Packet Sniffer H/W module
developed by Linn Products Ltd and found in the IMG Pistachio SoC.
The module allows Ethernet packets to be parsed, matched against
a user-defined pattern and timestamped. It sits between a 100M
Ethernet MAC and PHY and is completely passive with respect to
Ethernet frames.

Selected packet bytes from matched packets and timestamp values are
returned through a H/W FIFO. Timestamps are provided to the module
through an externally generated Gray-encoded counter.

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
        space through AF_PACKET sockets. 

- Ethernet Packet Sniffer backend: provides the driver for the
        Linn Ethernet Packet Sniffer H/W modules.

The split between a core and backend modules allows for other
implementations to be added in the future apart of the Ethernet
packet sniffer presented in this patch set.

Changelog:

v4:
* More detailed documentation on driver usage (in snf_core.c) and 
  H/W operation (in platform.c)
* Some source file renaming in the core module.
* Rebased against linux-net-next

v3:
* Code moved into vendor specific directory
* Device tree binding updated and streamlined. Cyclecounter params
  are now calculated dynamically.

v2:
* Complete redesign of core framework to use netdev instead of 
the generic netlink framework
* Updated device tree binding
* A number of minor code improvements suggested by code review

Stathis Voukelatos (3):
  Linn Ethernet packet sniffer: device tree binding and vendor prefix
  Linn packet sniffer core framework
  Linn Ethernet packet sniffer driver

 .../bindings/net/linn-ether-packet-sniffer.txt     |  39 ++
 .../devicetree/bindings/vendor-prefixes.txt        |   1 +
 MAINTAINERS                                        |   6 +
 drivers/net/ethernet/Kconfig                       |   1 +
 drivers/net/ethernet/Makefile                      |   1 +
 drivers/net/ethernet/linn/Kconfig                  |  36 ++
 drivers/net/ethernet/linn/Makefile                 |  20 +
 .../linn/pkt-sniffer/backends/ether/Makefile       |  20 +
 .../linn/pkt-sniffer/backends/ether/channel.c      | 444 +++++++++++++++++++++
 .../linn/pkt-sniffer/backends/ether/channel.h      |  80 ++++
 .../ethernet/linn/pkt-sniffer/backends/ether/hw.h  |  46 +++
 .../linn/pkt-sniffer/backends/ether/platform.c     | 318 +++++++++++++++
 .../net/ethernet/linn/pkt-sniffer/core/Makefile    |  19 +
 .../net/ethernet/linn/pkt-sniffer/core/snf_core.c  | 344 ++++++++++++++++
 .../net/ethernet/linn/pkt-sniffer/core/snf_core.h  |  60 +++
 15 files changed, 1435 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/linn-ether-packet-sniffer.txt
 create mode 100644 drivers/net/ethernet/linn/Kconfig
 create mode 100644 drivers/net/ethernet/linn/Makefile
 create mode 100644 drivers/net/ethernet/linn/pkt-sniffer/backends/ether/Makefile
 create mode 100644 drivers/net/ethernet/linn/pkt-sniffer/backends/ether/channel.c
 create mode 100644 drivers/net/ethernet/linn/pkt-sniffer/backends/ether/channel.h
 create mode 100644 drivers/net/ethernet/linn/pkt-sniffer/backends/ether/hw.h
 create mode 100644 drivers/net/ethernet/linn/pkt-sniffer/backends/ether/platform.c
 create mode 100644 drivers/net/ethernet/linn/pkt-sniffer/core/Makefile
 create mode 100644 drivers/net/ethernet/linn/pkt-sniffer/core/snf_core.c
 create mode 100644 drivers/net/ethernet/linn/pkt-sniffer/core/snf_core.h

-- 
1.9.1
