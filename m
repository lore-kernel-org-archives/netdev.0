From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next V3 00/23] ptp: get ready for 2038
Date: Sun, 29 Mar 2015 23:11:50 +0200
Message-ID: <cover.1427662906.git.richardcochran@gmail.com>
Cc: <linux-kernel@vger.kernel.org>, Amir Vadai <amirv@mellanox.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Arnd Bergmann <arnd@linaro.org>,
	Baolin Wang <baolin.wang@linaro.org>,
	Ben Hutchings <ben@decadent.org.uk>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Chris Metcalf <cmetcalf@ezchip.com>,
	David Miller <davem@davemloft.net>,
	Frank Li <Frank.Li@freescale.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Luwei Zhou <b45643@freescale.com>,
	Matthew Vick <matthew.vick@intel.com>,
	Michael Chan <mchan@broadcom.com>,
	Prashant Sreedharan <prashant@broadcom.com>,
	Rayagond K <rayagond@vayavyalabs.com>,
	Shradha Shah <sshah@solarflare.com>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	Sonic Zha
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series converts the core driver methods of the PTP Hardware Clock
(PHC) subsystem to use the 64 bit version of the timespec structure,
making the core API ready for the year 2038.

In addition, I reviewed how each driver and device represents the time
value at the hardware register level.  Most of the drivers are ready,
but a few will need some work before the year 2038, as shown:

   Patch   Driver
   ------------------------------------------------
   12      drivers/net/ethernet/intel/igb/igb_ptp.c
   15 ?    drivers/net/ethernet/sfc/ptp.c
   16      drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c

The commit log messages document how each driver is ready or why it is
not ready.  For patch 15, I could not easily find out the hardware
representation of the time value, and so the SFC maintainers will have
to review their low level code in order to resolve any remaining
issues.

Thanks,
Richard

* ChangeLog
** V3
   - dp83640: use timespec64 throughout per Arnd's suggestion
   - tilegx: use timespec64 throughout per Chris' suggestion
   - add Jeff's acked-bys
** V2
   - use the new methods in the posix clock code right away (patch #3)

Richard Cochran (23):
  ptp: introduce get/set time methods with explicit 64 bit seconds.
  ptp: use the 64 bit gettime method for the SYS_OFFSET ioctl.
  ptp: use the 64 bit get/set time methods for the posix clock.
  ptp: blackfin: convert to the 64 bit get/set time methods.
  ptp: xgbe: convert to the 64 bit get/set time methods.
  ptp: bnx2x: convert to the 64 bit get/set time methods.
  ptp: tg3: convert to the 64 bit get/set time methods.
  ptp: fec: convert to the 64 bit get/set time methods.
  ptp: gianfar: convert to the 64 bit get/set time methods.
  ptp: e1000e: convert to the 64 bit get/set time methods.
  ptp: fm10k: convert to the 64 bit get/set time methods.
  ptp: i40e: convert to the 64 bit get/set time methods.
  ptp: igb: convert to the 64 bit get/set time methods.
  ptp: ixgbe: convert to the 64 bit get/set time methods.
  ptp: mlx4: convert to the 64 bit get/set time methods.
  ptp: sfc: convert to the 64 bit get/set time methods.
  ptp: stmmac: convert to the 64 bit get/set time methods.
  ptp: cpts: convert to the 64 bit get/set time methods.
  ptp: tilegx: convert to the 64 bit get/set time methods.
  ptp: dp83640: convert to the 64 bit get/set time methods.
  ptp: ixp46x: convert to the 64 bit get/set time methods.
  ptp: pch: convert to the 64 bit get/set time methods.
  ptp: remove 32 bit get/set methods.

 arch/tile/gxio/mpipe.c                           |    4 +--
 arch/tile/include/gxio/mpipe.h                   |    4 +--
 drivers/net/ethernet/adi/bfin_mac.c              |    8 ++---
 drivers/net/ethernet/amd/xgbe/xgbe-ptp.c         |   13 +++----
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    8 ++---
 drivers/net/ethernet/broadcom/tg3.c              |   10 +++---
 drivers/net/ethernet/freescale/fec_ptp.c         |    8 ++---
 drivers/net/ethernet/freescale/gianfar_ptp.c     |   13 +++----
 drivers/net/ethernet/intel/e1000e/ptp.c          |   16 ++++-----
 drivers/net/ethernet/intel/fm10k/fm10k_ptp.c     |   12 +++----
 drivers/net/ethernet/intel/i40e/i40e_ptp.c       |   26 +++++++-------
 drivers/net/ethernet/intel/igb/igb_ptp.c         |   41 +++++++++++-----------
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c     |   14 ++++----
 drivers/net/ethernet/mellanox/mlx4/en_clock.c    |   11 +++---
 drivers/net/ethernet/sfc/ptp.c                   |   22 ++++++------
 drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c |    8 ++---
 drivers/net/ethernet/ti/cpts.c                   |   12 +++----
 drivers/net/ethernet/tile/tilegx.c               |    9 ++---
 drivers/net/phy/dp83640.c                        |   19 +++++-----
 drivers/ptp/ptp_chardev.c                        |    8 ++---
 drivers/ptp/ptp_clock.c                          |   12 +++++--
 drivers/ptp/ptp_ixp46x.c                         |    8 ++---
 drivers/ptp/ptp_pch.c                            |    8 ++---
 include/linux/ptp_clock_kernel.h                 |   12 +++----
 24 files changed, 160 insertions(+), 146 deletions(-)

-- 
1.7.10.4
