From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/13][pull request] 40GbE Intel Wired LAN Driver Updates 2017-02-18
Date: Sat, 18 Feb 2017 22:33:28 -0800
Message-ID: <20170219063341.8039-1-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:52390 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750847AbdBSGeK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 19 Feb 2017 01:34:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf only.

Alan fixes a bug in which the driver is unable to exit overflow
promiscuous mode after having added "too many" mac filters.  Ractored
the '%*ph' printk format specifier to instead use the print_hex_dump().

Josh adds enabling multicast magic packet wakeup by adding calls to
the mac_address_write admin q function during power down to update the
PRTPM_SAH/SAL registers with the MC_MAG_EN bit.

Jake remove a duplicate call i40e_update_link_info(), since it does not
need to call it twice.  Fixes and issue where we calculating the wrong
switch id on big endian platforms.  Avoided sparse warning, by doing a
typecast to ensure the value is of the type expected by
csum_replace_by_diff().

Mitch fixes a memory leak by freeing resources during i40e_remove().
Cleans up some code confusion by adding a proper code comment.

Carolyn fixes a bug introduced with the addition of the per queue ITR
feature support in ethtool.  Cleans up a duplicate device id from the
PCI table.

Harshitha fixes a bug which causes the 'Link Detected' field in
ethtool to report the correct link status.

Benjamin Poirier from SuSE applies a fix ec13ee80145c ("virtio_net:
 invoke softirqs after __napi_schedule") to i40e driver as well.

The following are changes since commit 4e33e34625103593a71d2bae471ce49cef62ef06:
  tcp: use page_ref_inc() in tcp_sendmsg()
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 40GbE

Alan Brady (2):
  i40e: fix disable overflow promiscuous mode
  i40e: refactor AQ CMD buffer debug printing

Benjamin Poirier (1):
  i40e: Invoke softirqs after napi_reschedule

Carolyn Wyborny (2):
  i40e: Fix Adaptive ITR enabling
  i40e: remove duplicate device id from PCI table

Harshitha Ramamurthy (1):
  i40e: Error handling for link event

Jacob Keller (4):
  i40e: remove unnecessary call to i40e_update_link_info
  i40e: convert to cpu from le16 to generate switch_id correctly
  i40e: properly convert le16 value to CPU format
  i40e: mark the value passed to csum_replace_by_diff as __wsum

Joshua Hay (1):
  i40e: enable mc magic pkt wakeup during power down

Mitch Williams (2):
  i40evf: free rings in remove function
  i40evf: add comment

 drivers/net/ethernet/intel/i40e/i40e.h            |   2 +
 drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h |   2 +
 drivers/net/ethernet/intel/i40e/i40e_common.c     |  19 ++--
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c    |   5 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c       | 115 +++++++++++++++++-----
 drivers/net/ethernet/intel/i40e/i40e_txrx.c       |  17 ++--
 drivers/net/ethernet/intel/i40evf/i40e_common.c   |  19 ++--
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c     |  17 ++--
 drivers/net/ethernet/intel/i40evf/i40evf_main.c   |   8 +-
 9 files changed, 147 insertions(+), 57 deletions(-)

-- 
2.11.0
