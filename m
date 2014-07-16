From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/5][pull request] Intel Wired LAN Driver Updates 2014-07-16
Date: Wed, 16 Jul 2014 14:35:29 -0700
Message-ID: <1405546534-21025-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:28351 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752197AbaGPVgL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jul 2014 17:36:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e only.

Neerav adds support to get the port MAC address from firmware and adds
support to the ndo_get_phys_port_id() callback to provide port specific
unique ids to the netdev layer.

Jakub Kicinski provides 2 fixes, first fixes i40e to never generate a software
time stamp if the hardware time stamp is provided.  Second fixes a race
condition on queueing skb for hardware time by using a simple bit lock to
avoid race conditions and leaking skbs when multiple transmit rings try
to claim time stamping.

Paul does some general cleanup of the driver to remove unneeded spaces,
comments that are no longer valid, and break that will never get touched.

Jacob Keller adds a verbose warning message when the incorrect PF attempts
to control timestamping for a port to which it was not assigned.  The primary
intent of this message is to help debugging the reason why the SIOCSHWSTAMP
ioctl has failed and to help narrow the cause of the issue.

The following are changes since commit a84bc2a9013fb123deeca7283480955d021503fb:
  drivers: net: cpsw: disable coalesce when rx_coalesce_usecs is zero
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Jacob Keller (1):
  i40e: (ptp) warn when PF_ID does not match in PRTTSYN_CTL0

Jakub Kicinski (2):
  i40e: never generate both software and hardware timestamps
  i40e: fix race conditions on queuing skb for HW time stamp

Neerav Parikh (1):
  i40e: Add ndo_get_phys_port_id() callback support

Paul M Stillwell Jr (1):
  i40e/i40evf: Clean up code

 drivers/net/ethernet/intel/i40e/i40e.h           |  2 ++
 drivers/net/ethernet/intel/i40e/i40e_adminq.c    |  2 +-
 drivers/net/ethernet/intel/i40e/i40e_common.c    | 26 +++++++++++++++++++++++-
 drivers/net/ethernet/intel/i40e/i40e_main.c      | 23 +++++++++++++++++++--
 drivers/net/ethernet/intel/i40e/i40e_prototype.h |  4 ++--
 drivers/net/ethernet/intel/i40e/i40e_ptp.c       | 10 +++++++--
 drivers/net/ethernet/intel/i40e/i40e_txrx.c      |  8 ++++----
 drivers/net/ethernet/intel/i40e/i40e_type.h      |  1 +
 drivers/net/ethernet/intel/i40evf/i40e_adminq.c  |  2 +-
 9 files changed, 65 insertions(+), 13 deletions(-)

-- 
1.9.3
