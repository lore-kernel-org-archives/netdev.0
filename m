From: Aaron Young <Aaron.Young@oracle.com>
Subject: [PATCH net-next 0/4] ldmvsw: Add ldmvsw driver
Date: Tue,  8 Mar 2016 07:02:32 -0800
Message-ID: <cover.1457401532.git.Aaron.Young@oracle.com>
Cc: netdev@vger.kernel.org, sowmini.varadhan@oracle.com,
	alexandre.chartre@oracle.com, rashmi.narasimhan@oracle.com,
	aaron.young@oracle.com, Aaron Young <Aaron.Young@oracle.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:45963 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751516AbcCHPEO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2016 10:04:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aaron Young <aaron.young@oracle.com>

This series adds a new Logical Domains vSwitch (ldmvsw) driver.

The ldmvsw driver code will live in the drivers/net/ethernet/sun/
directory and will operate on Oracle systems running SPARC Linux in a
Logical Domains environment (typically in the control domain).

The ldmvsw driver is very similar in function to the existing sunvnet
driver. Ldmvsw creates a network interface for each "vsw-port" node
found in the Machine Description (MD) of a service domain. These
nodes correspond to ports on a vswitch created by the logical domains
manager. The created network interface(s) can be used by bridge/vswitch
software (such as the Linux bridge or Open vSwitch) to provide
guest domain(s) with network interconnectivity or connectivity
to a physical network.

Here is a example diagram of ldmvsw driver usage in a logical
domain environment to provide a guest domain with network connectivity
to a physical NIC on the service domain:

   +----------------+             +-----------------
   | Service Domain |             |  Guest domain  |
   |                |             |                |
   |  LinuxBridge   |             |                |
   |    |    |      |             |                |
   |   NIC Ldmvsw   |             |    Sunvnet     |
   +----------------+             +----------------+
        |    |           LDC              |
       LAN   ------------------------------

As stated, the sunvnet and ldmvsw drivers are _very_ similar in function.
They both create network interface(s) to receive/transmit network
traffic across LDC network channel(s). Since the driver is so similar
in function to sunvnet, the approach will be as follows to integrate
the driver and take advantage of common code:

Patch #1: Split sunvnet.c driver into sunvnet.c and sunvnet_common.c
Patch #2: Modify the sunvnet_common code and data structures to be compatible
          with both the sunvnet and ldmvsw drivers.
Patch #3: Add the new ldmvsw.c driver code
Patch #4: Checkpatch cleanup of the sunvnet/sunvnet_common code.

NOTE - Patch#1 renames a file (sunvnet.h -> sunvnet_common.h). When generating
the patches (using git format-patch), I had to use the --no-renames option
otherwise patch#1 would NOT apply using 'patch -p1' - which as I
understand is a requirement for patch acceptance. I wasn't sure if this
is proper thing to do.  Please advise if not. Thanks.

Aaron Young (4):
  net-next: ldmvsw: Split sunvnet driver into common code
  net-next: ldmvsw: Make sunvnet_common compatible with ldmvsw
  net-next: ldmvsw: Add ldmvsw.c driver code
  net-next: ldmvsw: Checkpatch sunvnet.c and sunvnet_common.c

 arch/sparc/configs/sparc64_defconfig      |    1 +
 drivers/net/ethernet/sun/Kconfig          |   16 +
 drivers/net/ethernet/sun/Makefile         |    2 +
 drivers/net/ethernet/sun/ldmvsw.c         |  460 ++++++++
 drivers/net/ethernet/sun/sunvnet.c        | 1755 +----------------------------
 drivers/net/ethernet/sun/sunvnet.h        |  114 --
 drivers/net/ethernet/sun/sunvnet_common.c | 1732 ++++++++++++++++++++++++++++
 drivers/net/ethernet/sun/sunvnet_common.h |  145 +++
 8 files changed, 2413 insertions(+), 1812 deletions(-)
 create mode 100644 drivers/net/ethernet/sun/ldmvsw.c
 delete mode 100644 drivers/net/ethernet/sun/sunvnet.h
 create mode 100644 drivers/net/ethernet/sun/sunvnet_common.c
 create mode 100644 drivers/net/ethernet/sun/sunvnet_common.h
