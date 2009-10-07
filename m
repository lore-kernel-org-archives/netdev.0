From: David Daney <ddaney@caviumnetworks.com>
Subject: [PATCH 0/6] netdev: Octeon MGMT new driver + octeon_ethernet updates.
Date: Wed, 07 Oct 2009 16:07:58 -0700
Message-ID: <4ACD1F4E.8090603@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Ralf Baechle <ralf@linux-mips.org>,
	linux-mips <linux-mips@linux-mips.org>, netdev@vger.kernel.org
Return-path: <linux-mips-bounce@linux-mips.org>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

The main thrust of this patch set is to add a driver for the Cavium
Networks Octeon processor's MII (Management port) Ethernet devices.
Since it shares an mdio bus with the existing octeon-ethernet driver,
there is also some rearrangement of that code.

The Octeon SOC has an mdio bus that is shared by the PHYs of all the
Ethernet ports on the chip.  Patches 1/6 and 2/6 add a stand-alone
driver for the shared mdio bus

3/6 adds platform devices for the octeon_mgmt devices.

4/6 has the register definitions needed by the driver.

5/6 the octeon_mgmt driver proper

6/6 converts octeon_ethernet to use the PHYs on the shared mdio bus.


Since the Octeon is a mips based device, we may want to merge some or
all of these patches via Ralf's tree.

I will reply with the 6 patches.

David Daney (6):
   MIPS: Octeon: Add platform device for MDIO buses.
   net: Add driver for Octeon MDIO buses.
   MIPS: Octeon: Add platform devices MGMT Ethernet ports.
   MIPS: Octeon: Add register definitions for MGMT Ethernet driver.
   netdev: Add Ethernet driver for Octeon MGMT devices.
   Staging: octeon-ethernet: Convert to use PHY Abstraction Layer.

  arch/mips/cavium-octeon/octeon-platform.c     |   88 ++
  arch/mips/include/asm/octeon/cvmx-agl-defs.h  | 1194 
+++++++++++++++++++++++++
  arch/mips/include/asm/octeon/cvmx-mixx-defs.h |  248 +++++
  arch/mips/include/asm/octeon/cvmx-smix-defs.h |  178 ++++
  drivers/net/Kconfig                           |    2 +
  drivers/net/Makefile                          |    2 +
  drivers/net/octeon/Kconfig                    |   10 +
  drivers/net/octeon/Makefile                   |    2 +
  drivers/net/octeon/octeon_mgmt.c              | 1175 
++++++++++++++++++++++++
  drivers/net/phy/Kconfig                       |   11 +
  drivers/net/phy/Makefile                      |    1 +
  drivers/net/phy/mdio-octeon.c                 |  180 ++++
  drivers/staging/octeon/Kconfig                |    3 +-
  drivers/staging/octeon/ethernet-mdio.c        |  202 ++---
  drivers/staging/octeon/ethernet-mdio.h        |    2 +-
  drivers/staging/octeon/ethernet-proc.c        |  112 ---
  drivers/staging/octeon/ethernet-rgmii.c       |   54 +-
  drivers/staging/octeon/ethernet-sgmii.c       |    2 +-
  drivers/staging/octeon/ethernet-xaui.c        |    2 +-
  drivers/staging/octeon/ethernet.c             |   68 +-
  drivers/staging/octeon/octeon-ethernet.h      |   15 +-
  21 files changed, 3255 insertions(+), 296 deletions(-)
  create mode 100644 arch/mips/include/asm/octeon/cvmx-agl-defs.h
  create mode 100644 arch/mips/include/asm/octeon/cvmx-mixx-defs.h
  create mode 100644 arch/mips/include/asm/octeon/cvmx-smix-defs.h
  create mode 100644 drivers/net/octeon/Kconfig
  create mode 100644 drivers/net/octeon/Makefile
  create mode 100644 drivers/net/octeon/octeon_mgmt.c
  create mode 100644 drivers/net/phy/mdio-octeon.c
