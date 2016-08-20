From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/15][pull request] 40GbE Intel Wired LAN Driver Updates 2016-08-19
Date: Fri, 19 Aug 2016 23:19:36 -0700
Message-ID: <1471673991-117115-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:37803 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751350AbcHTGTw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 20 Aug 2016 02:19:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf only.

Jake provides several patches, first just moves a function to co-locate
the two functions related to configuring RSS via the admin queue, which
should help in spotting bugs when comparing the two functions.  Fixed
an issue where commit e69ff813af35 ("i40e: rework the functions to
configure RSS with similar parameters") missed checking whether the seed
is NULL before using it and did not use the passed in *lut parameter.
Fixed an issue where a previous refactor missed i40e_vsi_config_rss()
and the values were being ignored, so checked for the fields and used
them instead of default values.  Lastly replaced calls to
create_singlethread_workqueue() with alloc_workqueue() to provide more
control over workqueue creation and allows explicit setting of the
desired mode of operation.

Mitch adds link speed to log messages and reports speed through ethtool.

Carolyn refactors tail bump check and fixes byte ordering problems found
when enabling this feature support.  Adds support for HMC resources and
profile commands for x722 firmware.

Heinrich Schuchardt fixes format identifiers from %u to %d since the
variable is defined as an integer.

Catherine fixes an issue where there was a race condition between the
completion of the client open and calls to the client ops, so ensured
that client ops are not called until we are sure client is open.

Harshitha makes sure that i40e_client_release() does not try to use
an adapter pointer which may not be initialized, so make sure it is.

Joe Perches fixes the use of the local macro XSTRINGIFY() to use
__stringify() instead.

Avinash corrects the mutex usage in client_subtask().  Fixed the RDMA
client to open again after reset since it is closed during a PF reset.

Jeff (me) clean up whitespace issues, where indentation was done
inconsistently and with spaces versus tabs.

The following are changes since commit dc833def42e7f2425f69d83a53bee054e80caea5:
  net/irda: remove pointless assignment/check
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 40GbE

Avinash Dayanand (2):
  i40e: Correcting mutex usage in client code
  i40evf: Open RDMA Client after reset

Carolyn Wyborny (3):
  i40e: refactor tail_bump check
  i40e: Fix byte ordering in ARP NS code for X722
  i40e: Add support for HMC resource and profile for X722

Catherine Sullivan (1):
  i40e: Check client is open before calling client ops

Harshitha Ramamurthy (1):
  i40e: Initialize pointer in client_release function

Heinrich Schuchardt (1):
  i40e: use matching format identifiers

Jacob Keller (4):
  i40e: move i40e_vsi_config_rss below i40e_get_rss_aq
  i40e: fix broken i40e_config_rss_aq function
  i40e: use configured RSS key and lookup table in i40e_vsi_config_rss
  i40e: use alloc_workqueue instead of create_singlethread_workqueue

Jeff Kirsher (1):
  i40e/i40evf: Fix indentation

Joe Perches (1):
  i40e: Remove XSTRINGIFY macro definitions and uses

Mitch Williams (1):
  i40evf: report link speed

 drivers/net/ethernet/intel/i40e/i40e.h             | 135 ++++++++++-----------
 drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h  |  59 ++++++---
 drivers/net/ethernet/intel/i40e/i40e_client.c      |  30 ++++-
 drivers/net/ethernet/intel/i40e/i40e_client.h      |   6 +-
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |  26 ++--
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 127 +++++++++----------
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        |   6 +-
 .../net/ethernet/intel/i40evf/i40e_adminq_cmd.h    |  59 ++++++---
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      |   6 +-
 drivers/net/ethernet/intel/i40evf/i40evf.h         |  58 ++++-----
 drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c |  26 +++-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |   5 +-
 .../net/ethernet/intel/i40evf/i40evf_virtchnl.c    |  55 +++++++--
 13 files changed, 367 insertions(+), 231 deletions(-)

-- 
2.7.4
