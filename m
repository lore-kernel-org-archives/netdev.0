From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 00/14] net: provide common RSS key infrastructure
Date: Sun, 16 Nov 2014 06:23:04 -0800
Message-ID: <1416147798-16561-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Thomas Lendacky <Thomas.Lendacky@amd.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Michael Chan <mchan@broadcom.com>,
	Prashant Sreedharan <prashant@broadcom.com>,
	Rasesh Mody <rasesh.mody@qlogic.com>,
	Sathya Perla <sathya.perla@emulex.com>,
	Subbu Seetharaman <subbu.seetharaman@emulex.com>,
	Ajit Khaparde <ajit.khaparde@emulex.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Amir Vadai <amirv@mellanox.com>,
	Shradha Shah <sshah@solarflare.com>,
	Shreyas Bhatewara <sbhatewara@vmware.com>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f73.google.com ([209.85.218.73]:58290 "EHLO
	mail-oi0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752806AbaKPOXb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Nov 2014 09:23:31 -0500
Received: by mail-oi0-f73.google.com with SMTP id a141so548904oig.2
        for <netdev@vger.kernel.org>; Sun, 16 Nov 2014 06:23:31 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RSS (Receive Side Scaling) uses a 40 bytes key to provide hash for incoming
packets to select appropriate incoming queue on NIC.

Hash algo (Toeplitz) is also well known and documented by Microsoft
(search for "Verifying the RSS Hash Calculation")

Problem is that some drivers use a well known key.
It makes very easy for attackers to target one particular RX queue,
knowing that number of RX queues is a power of two, or at least some
small number.

Other drivers use a random value per port, making difficult
tuning on bonding setups.

Lets add a common infrastructure, so that host gets an unique
RSS key, and drivers do not have to worry about this.

Eric Dumazet (14):
  net: provide a per host RSS key generic infrastructure
  amd-xgbe: use netdev_rss_key_fill() helper
  bnx2x: use netdev_rss_key_fill() helper
  tg3: use netdev_rss_key_fill() helper
  bna: use netdev_rss_key_fill() helper
  be2net:use netdev_rss_key_fill() helper
  e100e: use netdev_rss_key_fill() helper
  fm10k: use netdev_rss_key_fill() helper
  i40e: use netdev_rss_key_fill() helper
  igb: use netdev_rss_key_fill() helper
  ixgbe: use netdev_rss_key_fill() helper
  mlx4: use netdev_rss_key_fill() helper
  sfc: use netdev_rss_key_fill() helper
  vmxnet3: use netdev_rss_key_fill() helper

 Documentation/sysctl/net.txt                    | 22 ++++++++++++++++++++++
 drivers/net/ethernet/amd/xgbe/xgbe-main.c       |  2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |  2 +-
 drivers/net/ethernet/broadcom/tg3.c             | 17 ++++++-----------
 drivers/net/ethernet/brocade/bna/bnad.c         |  2 +-
 drivers/net/ethernet/emulex/benet/be_main.c     | 10 +++++-----
 drivers/net/ethernet/intel/e1000e/netdev.c      |  9 +++------
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c    | 10 +++-------
 drivers/net/ethernet/intel/i40e/i40e_main.c     | 10 +++-------
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 11 +++--------
 drivers/net/ethernet/intel/igb/igb_main.c       |  9 +++------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c   |  7 +++----
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |  9 ++++++++-
 drivers/net/ethernet/mellanox/mlx4/en_rx.c      |  6 +-----
 drivers/net/ethernet/sfc/efx.c                  |  2 +-
 drivers/net/vmxnet3/vmxnet3_drv.c               |  9 +--------
 include/linux/mlx4/qp.h                         |  4 +++-
 include/linux/netdevice.h                       |  6 ++++++
 net/core/ethtool.c                              | 11 +++++++++++
 net/core/sysctl_net_core.c                      | 19 +++++++++++++++++++
 20 files changed, 104 insertions(+), 73 deletions(-)

-- 
2.1.0.rc2.206.gedb03e5
