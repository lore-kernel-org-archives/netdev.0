From: Alexander Gordeev <agordeev@redhat.com>
Subject: [PATCH 00/34] net: Use pci_enable_msix_range()
Date: Fri, 31 Jan 2014 16:46:18 +0100
Message-ID: <cover.1391172839.git.agordeev@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "VMware, Inc." <pv-drivers@vmware.com>, linux-pci@vger.kernel.org,
	Dimitris Michailidis <dm@chelsio.com>,
	Shreyas Bhatewara <sbhatewara@vmware.com>,
	Rasesh Mody <rmody@brocade.com>, Eli Cohen <eli@mellanox.com>,
	Sujith Sankar <ssujith@cisco.com>, e1000-devel@lists.sourceforge.net,
	Jingoo Han <jg1.han@samsung.com>, Amir Vadai <amirv@mellanox.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Manish Chopra <manish.chopra@qlogic.com>,
	Alexander Gordeev <agordeev@redhat.com>,
	Govindarajulu Varadarajan <govindarajulu90@gmail.com>,
	Santosh Raspatur <santosh@chelsio.com>, Casey Leedom <leedom@chelsio.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>,
	Sony Chacko <sony.chacko@qlogic.com>,
	Ajit Khaparde <ajit.khaparde@emulex.com>,
	Shradha Shah <sshah@solarflare.com>, Ron Mercer <ron.mercer@qlogic.com>,
	Michael Chan <mchan@broadcom.com>,
	Subbu Seetharaman <subbu.seetharaman@emul
To: linux-kernel@vger.kernel.org
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

As result of deprecation of MSI-X/MSI enablement functions
pci_enable_msix() and pci_enable_msi_block() all drivers
using these two interfaces need to be updated to use the
new pci_enable_msi_range() and pci_enable_msix_range()
interfaces.

Alexander Gordeev (34):
  bnx2: Use pci_enable_msix_range()
  bnx2x: Use pci_enable_msix_range()
  tg3: Use pci_enable_msix_range()
  bna: Use pci_enable_msix_range()
  cxgb3: Remove superfluous call to pci_disable_msix()
  cxgb3: Use pci_enable_msix_range()
  cxgb4: Use pci_enable_msix_range()
  cxgb4vf: Remove superfluous call to pci_disable_msix()
  cxgb4vf: Use pci_enable_msix_range()
  enic: Use pci_enable_msix_range()
  benet: Use pci_enable_msix_range()
  e1000e: Use pci_enable_msix_range()
  i40e: Use pci_enable_msix_range()
  igb: Use pci_enable_msix_range()
  igbvf: Use pci_enable_msix_range()
  ixgbe: Use pci_enable_msix_range()
  ixgbevf: Use pci_enable_msix_range()
  mlx4: Use pci_enable_msix_range()
  mlx5: Use pci_enable_msix_range()
  myri10ge: Use pci_enable_msix_range()
  s2io: Use pci_enable_msix_range()
  vxge: Use pci_enable_msix_range()
  forcedeth: Fix invalid errno reporting in nv_request_irq()
  forcedeth: Cleanup MSI-X to MSI to INTx fallback code
  forcedeth: Use pci_enable_msix_range()
  netxen: Use pci_enable_msix_range()
  qlcnic: Cleanup qlcnic_enable_msix() return values
  qlcnic: Use pci_enable_msix_range()
  qlge: Get rid of an redundant assignment
  qlge: Use pci_enable_msix_range()
  efx: Use pci_enable_msix_range()
  niu: Use pci_enable_msix_range()
  vmxnet3: Fix MSI-X/MSI enablement code
  vmxnet3: Use pci_enable_msix_range()

 drivers/net/ethernet/broadcom/bnx2.c               |   15 +--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c    |   48 ++++-----
 drivers/net/ethernet/broadcom/tg3.c                |    6 +-
 drivers/net/ethernet/brocade/bna/bnad.c            |   23 ++---
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c    |   26 ++---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |   50 +++++-----
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    |   35 +++----
 drivers/net/ethernet/cisco/enic/enic_main.c        |    6 +-
 drivers/net/ethernet/emulex/benet/be_main.c        |   31 +++---
 drivers/net/ethernet/intel/e1000e/netdev.c         |    9 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c        |   33 +-----
 drivers/net/ethernet/intel/igb/igb_main.c          |    9 +-
 drivers/net/ethernet/intel/igbvf/netdev.c          |    6 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c       |   16 +--
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c  |   33 ++----
 drivers/net/ethernet/mellanox/mlx4/main.c          |   19 +---
 drivers/net/ethernet/mellanox/mlx5/core/main.c     |   16 +--
 drivers/net/ethernet/myricom/myri10ge/myri10ge.c   |   32 +++---
 drivers/net/ethernet/neterion/s2io.c               |    5 +-
 drivers/net/ethernet/neterion/vxge/vxge-main.c     |   15 ++-
 drivers/net/ethernet/nvidia/forcedeth.c            |   41 +++++---
 .../net/ethernet/qlogic/netxen/netxen_nic_main.c   |    5 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |   18 ++--
 drivers/net/ethernet/qlogic/qlge/qlge_main.c       |   16 +--
 drivers/net/ethernet/sfc/efx.c                     |   20 ++--
 drivers/net/ethernet/sun/niu.c                     |   11 +--
 drivers/net/vmxnet3/vmxnet3_drv.c                  |  110 ++++++++-----------
 27 files changed, 274 insertions(+), 380 deletions(-)

-- 
1.7.7.6


------------------------------------------------------------------------------
WatchGuard Dimension instantly turns raw network data into actionable 
security intelligence. It gives you real-time visual feedback on key
security issues and trends.  Skip the complicated setup - simply import
a virtual appliance and go from zero to informed in seconds.
http://pubads.g.doubleclick.net/gampad/clk?id=123612991&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
