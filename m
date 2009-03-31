From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH 00/14] Add common OF device tree support for MDIO busses
Date: Tue, 31 Mar 2009 02:26:43 -0600
Message-ID: <20090331075537.1427.7819.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olof@lixom.net, afleming@freescale.com,
	Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
To: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

This series adds common code for reading PHY connection data out of
the OpenFirmware device tree.  This simplifies the network drivers
which use the device tree and which currently implement their own
solutions for reading the PHY data out of the device tree directly.

This series was depending on changes in both the netdev and powerpc
-next trees.  Now that both trees have been merged by Linus, I'm
able to post this series in a usable form.

David, as I mentioned below, I'd really like to get the core changes
(1, 4, 5  6) merged into 2.6.30 (assuming Andy confirms they are okay).
Due to dependencies, I think it is easiest if all of them go in via the
same tree.  Are you willing to merge them via yours?  Two of the patches
are outside of drivers/net (patches 1 and 6 touch drivers/of/), but I
personally have no issues if those changes go through you.  I just need
to double check with BenH.

Patches 1, 4, 5 and 6 are the core changes.  They have been tested and
I think they are ready to be merged.  Andy, can you please reply and
confirm that you're okay with these 4?  I'd like to see them go in the
2.6.30 merge window.
	[01/14] of: add of_parse_phandle() helper for parsing phandle
	[04/14] phylib: rework to prepare for OF registration of PHYs
	[05/14] phylib: add *_direct() variants of phy_connect and phy_attach
	[06/14] openfirmware: Add OF phylib support code

Patches 2, 3, and 7 (sorry about the funny ordering) are changes to the
fec_mpc52xx driver.  Actually, 2 & 3 are a cleanup and bug fix, but
patch 7 depends on them so I'm including them here.  All three are
tested and working.
	[02/14] net/fec_mpc52xx: Migrate to net_device_ops.
	[03/14] net/fec_mpc52xx: Don't dereference phy_device if it is NULL
	[07/14] net: Rework mpc5200 fec driver to use of_mdio infrastructure.

Patches 8, 9, 10, 12 & 13 are compile tested, but not tested with
hardware.  They are not ready to be merged, and I would like it if
someone with hardware can try them out.  I need to review these ones
again.
	[08/14] net: rework fsl_pq_mdio driver to use of_mdio infrastructure
	[09/14] net: Rework gianfar driver to use of_mdio infrastructure.
	[10/14] net: Rework ucc_geth driver to use of_mdio infrastructure
	[12/14] powerpc/82xx: Rework Embedded Planet ep8248e platform to use of_mdio
	[13/14] net: Rework fs_enet driver to use of_mdio infrastructure

Patch 11 has been tested by Olof Johansson.  It is ready to be merged.
	[11/14] net: Rework pasemi_mac driver to use of_mdio infrastructure

Patch 14 is a new Ethernet driver.  It needs review, but it has been
tested with the new of_mdio infrastructure.  It is not ready.
	[14/14] net: add Xilinx ll_temac device driver

For those who are interested, I've pushed these changes out to by git
server along with a bug fix patch to fec_52xx.c:

The following changes since commit 15f7176eb1cccec0a332541285ee752b935c1c85:
  Linus Torvalds (1):
        Merge git://git.kernel.org/.../davem/net-2.6

are available in the git repository at:

  git://git.secretlab.ca/git/linux-2.6-mpc52xx for-davem

Grant Likely (15):
      net/fec_mpc52xx: fix BUG on missing dma_ops
      of: add of_parse_phandle() helper for parsing phandle properties
      net/fec_mpc52xx: Migrate to net_device_ops.
      net/fec_mpc52xx: Don't dereference phy_device if it is NULL
      phylib: rework to prepare for OF registration of PHYs
      phylib: add *_direct() variants of phy_connect and phy_attach functions
      openfirmware: Add OF phylib support code
      net: Rework mpc5200 fec driver to use of_mdio infrastructure.
      net: rework fsl_pq_mdio driver to use of_mdio infrastructure
      net: Rework gianfar driver to use of_mdio infrastructure.
      net: Rework ucc_geth driver to use of_mdio infrastructure
      net: Rework pasemi_mac driver to use of_mdio infrastructure
      powerpc/82xx: Rework Embedded Planet ep8248e platform to use of_mdio
      net: Rework fs_enet driver to use of_mdio infrastructure
      net: add Xilinx ll_temac device driver

 arch/powerpc/platforms/82xx/ep8248e.c     |    9 +-
 arch/powerpc/platforms/pasemi/gpio_mdio.c |   32 +-
 drivers/net/Kconfig                       |    8 +
 drivers/net/Makefile                      |    2 +
 drivers/net/fec_mpc52xx.c                 |  256 +++-----
 drivers/net/fec_mpc52xx_phy.c             |   26 +-
 drivers/net/fs_enet/fs_enet-main.c        |   69 +--
 drivers/net/fs_enet/mii-bitbang.c         |   29 +-
 drivers/net/fs_enet/mii-fec.c             |   26 +-
 drivers/net/fsl_pq_mdio.c                 |   53 +--
 drivers/net/gianfar.c                     |  103 ++--
 drivers/net/gianfar.h                     |    3 +-
 drivers/net/pasemi_mac.c                  |   28 +-
 drivers/net/pasemi_mac.h                  |    1 -
 drivers/net/phy/mdio_bus.c                |   29 +-
 drivers/net/phy/phy_device.c              |  163 ++++--
 drivers/net/ucc_geth.c                    |   47 +-
 drivers/net/ucc_geth.h                    |    2 +-
 drivers/net/xilinx_temac.c                |  970 +++++++++++++++++++++++++++++
 drivers/net/xilinx_temac.h                |  374 +++++++++++
 drivers/net/xilinx_temac_mdio.c           |  119 ++++
 drivers/of/Kconfig                        |    6 +
 drivers/of/Makefile                       |    1 +
 drivers/of/base.c                         |   24 +
 drivers/of/of_mdio.c                      |  139 ++++
 include/linux/fs_enet_pd.h                |    6 +-
 include/linux/of.h                        |    3 +
 include/linux/of_mdio.h                   |   22 +
 include/linux/phy.h                       |    6 +
 29 files changed, 1990 insertions(+), 566 deletions(-)
 create mode 100644 drivers/net/xilinx_temac.c
 create mode 100644 drivers/net/xilinx_temac.h
 create mode 100644 drivers/net/xilinx_temac_mdio.c
 create mode 100644 drivers/of/of_mdio.c
 create mode 100644 include/linux/of_mdio.h

Secret Lab Technologies Ltd.
