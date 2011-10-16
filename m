From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/5 v2][pull request] Intel Wired LAN Driver Updates
Date: Sun, 16 Oct 2011 13:36:58 -0700
Message-ID: <1318797423-19897-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:38517 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751379Ab1JPUhG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Oct 2011 16:37:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series contains updates to e1000e, if_link, ixgbe, igbvf
and igb.  This version of the series contains the following changes:

- e1000e not sure what happened in the pull on Tuesday which has this f=
ix
  so re-posting this fix
- igb enable L4 timestamping
- igbvf final conversion to ndo_fix_features
- if_link/ixgbe add spoof checking feature

-v2 drop the igb fix for timecompare_update

The following are changes since commit 96cd8951684adaa5fd72952adef532d0=
b42f70e1:
  ftmac100: fix skb truesize underestimation
and are available in the git repository at
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next.git

Bruce Allan (1):
  e1000e: locking bug introduced by commit 67fd4fcb

Greg Rose (2):
  if_link: Add additional parameter to IFLA_VF_INFO for spoof checking
  ixgbe: Add new netdev op to turn spoof checking on or off per VF

Jacob Keller (1):
  igb: enable l4 timestamping for v2 event packets

Micha=C5=82 Miros=C5=82aw (1):
  igbvf: convert to ndo_fix_features

 drivers/net/ethernet/intel/e1000e/e1000.h      |    1 +
 drivers/net/ethernet/intel/e1000e/ich8lan.c    |   21 +++++---
 drivers/net/ethernet/intel/igb/igb_main.c      |    1 +
 drivers/net/ethernet/intel/igbvf/ethtool.c     |   57 ----------------=
--------
 drivers/net/ethernet/intel/igbvf/netdev.c      |   25 ++++++++--
 drivers/net/ethernet/intel/ixgbe/ixgbe.h       |    3 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  |   10 +++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c |   48 ++++++++++++++++=
+---
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h |    1 +
 include/linux/if_link.h                        |   10 ++++
 include/linux/netdevice.h                      |    3 +
 net/core/rtnetlink.c                           |   33 ++++++++++++-
 12 files changed, 130 insertions(+), 83 deletions(-)

--=20
1.7.6.4
