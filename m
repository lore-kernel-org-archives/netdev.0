From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 00/11][pull request] 40GbE Intel Wired LAN Driver Updates 2015-12-12
Date: Sat, 12 Dec 2015 21:17:26 -0800
Message-ID: <1449983857-74434-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	john.ronciak@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:56992 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750720AbbLMFRj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Dec 2015 00:17:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf only.

Jesse fixes some trivial static analyzer warnings where BIT() can be used
instead of BIT_ULL().

Mitch fixes the virtual channel interface which was using incorrect semantics
to remove MAC addresses and would leave incorrect filters active when using
VLANs.  Also fixes an issue that when VF's are created, the MAC address
defaults to all zeros, indicating to the VF driver that it should use a
random MAC address.  However, the PF driver was incorrectly adding this
zero MAC to the filter table, so check for a good address before adding
the default filter.  Adds a check to make sure that the Tx and Rx rings
actually exist before dereferencing them to free resources.  Re-classifies
several messages which are really for debugging purposes, especially since
the driver can fully recover from any of these.  Fixed up the VF version
strings to match the PF driver.

Anjali adds a virtchnl offload to support the expanded version of TCP/UDP
PCTYPES for RSS.

Shannon fixes i40e to clean the whole MAC filter list when resetting after
an intermediate add or delete push to the firmware.

v2: added blank line after variable declaration in patch 9 based on
    feedback from Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

The following are changes since commit 1d72135dd6be396bf724cd962555758c0277db93:
  Merge branch '10GbE' of git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 40GbE

Anjali Singhai Jain (1):
  i40e/i40evf: Add a new offload for RSS PCTYPE V2 for X722

Catherine Sullivan (1):
  i40e/i40evf: Bump i40e to 1.4.8 and i40evf to 1.4.4

Jesse Brandeburg (1):
  i40e: chomp the BIT(_ULL)

Kamil Krawczyk (1):
  i40e: use explicit cast from u16 to u8

Michal Kosiarz (1):
  i40e: Opcode and structures required by OEM Post Update AQ command and
    add new NVM arq message

Mitch Williams (5):
  i40e: properly delete VF MAC filters
  i40e: don't add zero MAC filter
  i40evf: check rings before freeing resources
  i40e: hush little warnings
  i40evf: change version string generation

Shannon Nelson (1):
  i40e: clean whole mac filter list

 drivers/net/ethernet/intel/i40e/i40e.h             |   2 +
 drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h  |  21 ++++
 drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c     |   2 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 106 +++++++++++++++------
 drivers/net/ethernet/intel/i40e/i40e_virtchnl.h    |   1 +
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |  23 +++--
 .../net/ethernet/intel/i40evf/i40e_adminq_cmd.h    |  21 ++++
 drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h  |   1 +
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |  16 +++-
 .../net/ethernet/intel/i40evf/i40evf_virtchnl.c    |   4 +-
 10 files changed, 156 insertions(+), 41 deletions(-)

-- 
2.5.0
