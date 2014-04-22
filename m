From: Santosh Shilimkar <santosh.shilimkar@ti.com>
Subject: [PATCH 0/2] net: Add Keystone NetCP ethernet driver support
Date: Tue, 22 Apr 2014 17:21:13 -0400
Message-ID: <1398201675-17379-1-git-send-email-santosh.shilimkar@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	<devicetree@vger.kernel.org>,
	Santosh Shilimkar <santosh.shilimkar@ti.com>,
	David Miller <davem@davemloft.net>,
	Rob Herring <robh+dt@kernel.org>,
	Grant Likely <grant.likely@linaro.org>,
	Sandeep Nair <sandeep_n@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Couple of patches to add Keystone NetCP ethernet driver support.

The network coprocessor (NetCP) is a hardware accelerator that processes
Ethernet packets. NetCP has a gigabit Ethernet (GbE) subsystem with a ethernet
switch sub-module to send and receive packets. NetCP also includes a packet
accelerator (PA) module to perform packet classification operations such as
header matching, and packet modification operations such as checksum
generation. NetCP can also optionally include a Security Accelerator(SA)
capable of performing IPSec operations on ingress/egress packets.
    
Keystone SoC's also have a 10 Gigabit Ethernet Subsystem (XGbE) which
includes a 3-port Ethernet switch sub-module capable of 10Gb/s and
1Gb/s rates per Ethernet port.
    
NetCP driver has a plug-in module architecture where each of the NetCP
sub-modules exist as a loadable kernel module which plug in to the netcp
core. These sub-modules are represented as "netcp-devices" in the dts
bindings. It is mandatory to have the ethernet switch sub-module for
the ethernet interface to be operational. Any other sub-module like the
PA is optional.

Both GBE and XGBE network processors supported using common driver. It
is also designed to handle future variants of NetCP.

Cc: David Miller <davem@davemloft.net>
Cc: Rob Herring <robh+dt@kernel.org>
Cc: Grant Likely <grant.likely@linaro.org>
Cc: Sandeep Nair <sandeep_n@ti.com>

Sandeep Nair (2):
  Documentation: dt: net: Add binding doc for Keystone NetCP ethernet
    driver
  net: Add Keystone NetCP ethernet driver

 .../devicetree/bindings/net/keystone-netcp.txt     |  197 ++
 drivers/net/ethernet/ti/Kconfig                    |   16 +-
 drivers/net/ethernet/ti/Makefile                   |    4 +
 drivers/net/ethernet/ti/netcp.h                    |  226 ++
 drivers/net/ethernet/ti/netcp_core.c               | 2194 ++++++++++++++++++++
 drivers/net/ethernet/ti/netcp_ethss.c              | 2177 +++++++++++++++++++
 drivers/net/ethernet/ti/netcp_sgmii.c              |  130 ++
 drivers/net/ethernet/ti/netcp_xgbepcsr.c           |  502 +++++
 8 files changed, 5443 insertions(+), 3 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/keystone-netcp.txt
 create mode 100644 drivers/net/ethernet/ti/netcp.h
 create mode 100644 drivers/net/ethernet/ti/netcp_core.c
 create mode 100644 drivers/net/ethernet/ti/netcp_ethss.c
 create mode 100644 drivers/net/ethernet/ti/netcp_sgmii.c
 create mode 100644 drivers/net/ethernet/ti/netcp_xgbepcsr.c

-- 
1.7.9.5
