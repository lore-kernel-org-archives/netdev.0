From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/9][pull request] 40GbE Intel Wired LAN Driver Updates 2017-10-31
Date: Tue, 31 Oct 2017 11:40:03 -0700
Message-ID: <20171031184012.29690-1-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:21198 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932423AbdJaSkf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 31 Oct 2017 14:40:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e, i40evf and net/sched.

Arnd Bergmann cleans up the power management code to resolve a build
warning.

Shannon Nelson fixes i40e to only redistribute our vectors when we did
not get the full count that we requested.

Alex reverts a previous commit because it potentially causes a memory leak
when combined with the current page recycling scheme.

Amritha enables configuring cloud filters in i40e using the tc-flower
classifier.  The classification function of the filter is to match a
packet to a traffic class.  cls_flower is extended to offload classid to
hardware.  Hardware traffic classes are identified using classid values
reserved in the range :ffe0 - :ffef.
The cloud filters are added for a VSI and are cleaned up when the VSI is
deleted. The filters that match on L4 ports needs enhanced admin queue
functions with big buffer support for extended fields in cloud filter
commands.

The following are changes since commit aa2bc739ef4a181a7589eb009be96a870cc1788f:
  net: filter: remove unused variable and fix warning
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 40GbE

Alexander Duyck (1):
  i40e/i40evf: Revert "i40e/i40evf: bump tail only in multiples of 8"

Amritha Nambiar (6):
  net: sched: Identify hardware traffic classes using classid
  i40e: Map TCs with the VSI seids
  i40e: Cloud filter mode for set_switch_config command
  i40e: Admin queue definitions for cloud filters
  i40e: Clean up of cloud filters
  i40e: Enable cloud filters via tc-flower

Arnd Bergmann (1):
  i40e: mark PM functions as __maybe_unused

Shannon Nelson (1):
  i40e: only redistribute MSI-X vectors when needed

 drivers/net/ethernet/intel/i40e/i40e.h             |   62 ++
 drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h  |  140 ++-
 drivers/net/ethernet/intel/i40e/i40e_common.c      |  193 +++-
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |    2 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 1001 +++++++++++++++++++-
 drivers/net/ethernet/intel/i40e/i40e_prototype.h   |   18 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        |    9 -
 drivers/net/ethernet/intel/i40e/i40e_type.h        |   10 +
 .../net/ethernet/intel/i40evf/i40e_adminq_cmd.h    |  110 ++-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      |    9 -
 include/net/pkt_cls.h                              |    1 +
 include/net/sch_generic.h                          |    7 +
 net/sched/cls_flower.c                             |    2 +
 13 files changed, 1496 insertions(+), 68 deletions(-)

-- 
2.14.2
