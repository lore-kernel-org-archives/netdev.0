From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/17][pull request] Intel Wired LAN Driver Updates 2015-12-01
Date: Wed,  2 Dec 2015 00:25:18 -0800
Message-ID: <1449044735-68599-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	john.ronciak@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:44579 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752459AbbLBIZi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Dec 2015 03:25:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf only.

Helin adds new fields to i40e_vsi to store user configured RSS config data
and the code to use it.  Also renamed RSS items to clarify functionality
and scope to users.  Fixed a confusing kernel message of enabling RSS size
by reporting it together with the hardware maximum RSS size.

Anjali fixes the issue of forcing writeback too often causing us to not
benefit from NAPI.

Jesse adds a prefetch for data early in the transmit path to help immensely
for pktgen and forwarding workloads.  Fixed the i40e driver that was
possibly sleeping inside critical section of code.

Carolyn fixes an issue where adminq init failures always provided a message
that NVM was newer than expected, when this is not always the case for
init_adminq failures.  Fixed by adding a check for that specific error
condition and a different helpful message otherwise.

Mitch fixes error message by telling the user which VF is being naughty,
rather than making them guess.  Updated the queue_vector array from a
statically-sized member of the adapter structure, to a dynamically-allocated
and -sized array.  This reduces the size of the adapter structure and allows
us to support any number of queue vectors in the future without changing the
code.

The following are changes since commit 6cc568340148424e657508d82692ef787d6c4b2c:
  isdn: remove spellcaster driver
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 40GbE

Anjali Singhai Jain (1):
  i40e/i40evf: Fix RS bit update in Tx path and disable force WB
    workaround

Carolyn Wyborny (1):
  i40e: Update error messaging

Catherine Sullivan (1):
  i40e/i40evf: Bump i40e version to 1.4.4 and i40evf to 1.4.1

Helin Zhang (7):
  i40e: add new fields to store user configuration
  i40e: rename rss_size to alloc_rss_size in i40e_pf
  i40evf: rename VF adapter specific RSS function
  i40evf: create a generic config RSS function
  i40evf: create a generic get RSS function
  i40evf: add new fields to store user configuration of RSS
  i40e: fix confusing message

Jesse Brandeburg (3):
  i40e/i40evf: prefetch skb data on transmit
  i40e: fix: do not sleep in netdev_ops
  i40e: remove unused argument

Mitch Williams (4):
  i40e: make error message more useful
  i40evf: quoth the VF driver, Nevermore
  i40evf: allocate queue vectors dynamically
  i40evf: allocate ring structs dynamically

 drivers/net/ethernet/intel/i40e/i40e.h             |  12 +-
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c     |   4 +-
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |  31 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 158 +++++---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        |   3 +
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |  12 +-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      | 123 ++++---
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h      |   2 +
 drivers/net/ethernet/intel/i40evf/i40evf.h         |  16 +-
 drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c |  79 ++--
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    | 403 +++++++++++++++------
 .../net/ethernet/intel/i40evf/i40evf_virtchnl.c    |  12 +-
 12 files changed, 583 insertions(+), 272 deletions(-)

-- 
2.5.0
