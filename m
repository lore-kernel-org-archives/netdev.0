From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/15][pull request] 40GbE Intel Wired LAN Driver Updates 2016-02-17
Date: Wed, 17 Feb 2016 09:51:31 -0800
Message-ID: <1455731506-62165-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	john.ronciak@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:4789 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161411AbcBQRvt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2016 12:51:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e/i40evf only.

Jesse cleans up a duplicate declaration in probe.  Then fixes a bug where the
driver was using a offset based off a DMA handle while mapping and unmapping
using sync_single_range_for_[cpu|device], when it should be using DMA handle
(returned from alloc_coherent) and the offset of the memory to be sync'd.
Fixed an issue where sync_vsi_filter() was allocating memory in a way that
could sleep (GFP_KERNEL) which was causing a problem when called by the
team driver under rcu_read_lock().

Shannon adds a check to ensure we do not attempt to do TSO when
skb->ip_summed is not set to CHECKSUM_PARTIAL.

Kiran add functions related to port mirroring features such as add/delete
mirror rule.

Jacob assigns the i40e_pf structure directly instead of using a large
memcpy, to avoid a sparse warning and lets the compiler optimize the copy
since it know the size of the structure in advance.

Anjali enables GENEVE capability for XL710/X710 devices with firmware API
version higher than 1.4.  Added flag for automatic rule eviction feature 
for X722, which is disabled by default.

The following are changes since commit f55158859504ead847e56211f3dadadaf883a6ee:
  Merge branch '40GbE' of git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 40GbE

Anjali Singhai (1):
  i40e: Enable Geneve offload for FW API ver > 1.4 for XL710/X710
    devices

Anjali Singhai Jain (1):
  i40e: add priv flag for automatic rule eviction

Jacob Keller (1):
  i40e: avoid large memcpy by assigning struct

Jesse Brandeburg (8):
  i40e: trivial: drop duplicate definition
  i40e: trivial: fix missing space
  i40e: fix bug in dma sync
  i40e: allocate memory safer
  i40e: fix: do not sleep in netdev_ops
  i40e: drop unused function
  i40e: count allocation errors
  i40e/i40evf: bump version to 1.4.12/1.4.8

Kiran Patil (1):
  i40e: APIs to Add/remove port mirroring rules

Shannon Nelson (2):
  i40e: do TSO only if CHECKSUM_PARTIAL is set
  i40e: negate PHY int mask bits

Sowmini Varadhan (1):
  i40e: use eth_platform_get_mac_address()

 drivers/net/ethernet/intel/i40e/i40e.h           |   2 +-
 drivers/net/ethernet/intel/i40e/i40e_common.c    | 162 +++++++++++++++++++++++
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c   |   8 +-
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c   |  11 ++
 drivers/net/ethernet/intel/i40e/i40e_main.c      |  90 ++++++-------
 drivers/net/ethernet/intel/i40e/i40e_prototype.h |  12 ++
 drivers/net/ethernet/intel/i40e/i40e_txrx.c      |  17 ++-
 drivers/net/ethernet/intel/i40e/i40e_type.h      |   4 +
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c    |  11 +-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c  |   2 +-
 10 files changed, 254 insertions(+), 65 deletions(-)

-- 
2.5.0
