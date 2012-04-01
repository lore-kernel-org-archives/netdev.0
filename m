From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH V2 net-next 00/28] ethtool: support time
	stamping and phc clocks
Date: Sun,  1 Apr 2012 17:19:45 +0200
Message-ID: <cover.1333289292.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, Martin Porter <mporter@solarflare.com>,
	John Ronciak <john.ronciak@intel.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>, Jacob Keller <jacob.e.keller@intel.com>
To: <netdev@vger.kernel.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Support for SO_TIMESTAMPING of network packets and PTP Hardware Clocks
has been expanding over the last year or two. In an ideal world, every
host would have exactly one PTP hardware clock, and every Ethernet MAC
would support SO_TIMESTAMPING on both the transmit and receive paths.
However, since we do not yet have full coverage for these features,
user space programs need a way to discover what a given interface
supports in these two areas.

* PTP Hardware Clocks

  The relationship between the network interfaces and the (possibly
  multiple) PHC devices is not discoverable except by knowing what
  hardware you have got and carefully looking into the kernel log.

* SO_TIMESTAMPING

  - Receive software time stamps are implemented in the stack
    and thus work for all MAC hardware.
  - Transmit software time stamps are only supported by a dozen
    drivers or so.
  - Some special devices support Tx/Rx time stamping in hardware.
  - None of this is discoverable except by looking into the kernel
    sources.

This series exposes the hardware and driver capabilities known to user
space via ethtool. 

Since the PHC code was first merged, this has become the number one
requested new feature.

Patch number  3 applies on top of my recent two igb/phc patches.
Patch number 12 applies on top of my recent e100 patch.

The new feature has been tested on the following hardware:

igb       Hardware time stamping in the MAC
dp83640   Hardware time stamping in the PHY
r8169     Software Tx time stamping in the MAC

Thanks,
Richard


Richard Cochran (28):
  phc: Add a method for obtaining the device index.
  ethtool: Introduce a method for getting time stamping capabilities.
  igb: Support the get_ts_info ethtool method.
  dp83640: Support the get_ts_info ethtool method.
  gianfar: Support the get_ts_info ethtool method.
  bfin_mac: Support the get_ts_info ethtool method.
  ixp4xx_eth: Support the get_ts_info ethtool method.
  ethtool: Add a common function for drivers with transmit time
    stamping.
  ax88796: Support the get_ts_info ethtool method.
  davinci_emac: Support the get_ts_info ethtool method.
  dnet: Support the get_ts_info ethtool method.
  e100: Support the get_ts_info ethtool method.
  etherh: Support the get_ts_info ethtool method.
  fec_mpc52xx: Support the get_ts_info ethtool method.
  fec: Support the get_ts_info ethtool method.
  fs_enet: Support the get_ts_info ethtool method.
  ll_temac: Support the get_ts_info ethtool method.
  macb: Support the get_ts_info ethtool method.
  mv643xx_eth: Support the get_ts_info ethtool method.
  pxa168_eth: Support the get_ts_info ethtool method.
  r6040: Support the get_ts_info ethtool method.
  r8169: Support the get_ts_info ethtool method.
  smsc911x: Support the get_ts_info ethtool method.
  smsc9420: Support the get_ts_info ethtool method.
  stmmac: Support the get_ts_info ethtool method.
  tg3: Support the get_ts_info ethtool method.
  ucc_geth: Support the get_ts_info ethtool method.
  usbnet: Support the get_ts_info ethtool method.

 arch/arm/mach-ixp4xx/include/mach/ixp46x_ts.h      |    3 +
 drivers/net/ethernet/8390/ax88796.c                |    1 +
 drivers/net/ethernet/8390/etherh.c                 |    1 +
 drivers/net/ethernet/adi/bfin_mac.c                |   20 ++++++++
 drivers/net/ethernet/broadcom/tg3.c                |    1 +
 drivers/net/ethernet/cadence/macb.c                |    1 +
 drivers/net/ethernet/dnet.c                        |    1 +
 drivers/net/ethernet/freescale/fec.c               |    1 +
 drivers/net/ethernet/freescale/fec_mpc52xx.c       |    1 +
 .../net/ethernet/freescale/fs_enet/fs_enet-main.c  |    1 +
 drivers/net/ethernet/freescale/gianfar.h           |    3 +
 drivers/net/ethernet/freescale/gianfar_ethtool.c   |   29 ++++++++++++
 drivers/net/ethernet/freescale/gianfar_ptp.c       |    2 +
 drivers/net/ethernet/freescale/ucc_geth_ethtool.c  |    1 +
 drivers/net/ethernet/intel/e100.c                  |    1 +
 drivers/net/ethernet/intel/igb/igb_ethtool.c       |   31 +++++++++++++
 drivers/net/ethernet/marvell/mv643xx_eth.c         |    1 +
 drivers/net/ethernet/marvell/pxa168_eth.c          |    1 +
 drivers/net/ethernet/rdc/r6040.c                   |    1 +
 drivers/net/ethernet/realtek/r8169.c               |    1 +
 drivers/net/ethernet/smsc/smsc911x.c               |    1 +
 drivers/net/ethernet/smsc/smsc9420.c               |    1 +
 .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   |    1 +
 drivers/net/ethernet/ti/davinci_emac.c             |    1 +
 drivers/net/ethernet/xilinx/ll_temac_main.c        |    1 +
 drivers/net/ethernet/xscale/ixp4xx_eth.c           |   29 ++++++++++++
 drivers/net/phy/dp83640.c                          |   31 +++++++++++++
 drivers/net/usb/usbnet.c                           |    1 +
 drivers/ptp/ptp_clock.c                            |    6 +++
 drivers/ptp/ptp_ixp46x.c                           |    3 +
 include/linux/ethtool.h                            |   24 ++++++++++
 include/linux/phy.h                                |    3 +
 include/linux/ptp_clock_kernel.h                   |    8 +++
 net/core/ethtool.c                                 |   47 ++++++++++++++++++++
 34 files changed, 259 insertions(+), 0 deletions(-)

-- 
1.7.2.5


------------------------------------------------------------------------------
This SF email is sponsosred by:
Try Windows Azure free for 90 days Click Here 
http://p.sf.net/sfu/sfd2d-msazure
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
