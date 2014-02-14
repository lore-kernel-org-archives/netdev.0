From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 00/14] Intel Wired LAN Driver Updates
Date: Fri, 14 Feb 2014 14:57:54 -0800
Message-ID: <1392418688-23895-1-git-send-email-aaron.f.brown@intel.com>
Cc: Aaron Brown <aaron.f.brown@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:61878 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753059AbaBNXBT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Feb 2014 18:01:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and (mostly to) i40evf.

Mitch provides most the work for this series.  For the vf driver
he requests a reset on a tx hang, removes vlan filtes on close since
we already remove the MAC filters, fixes some crashes, gets rid of 
PCI DAC as it does not mean much on virtualized PCIe parts, skips
assigning the device name that just gets renamed anyway, stores the
descriptor ring size in a manner that allows the use of common tx
and rx code with the PF driver and makes a handful of cosmetic fixes.
For i40e he removes a delay left over from debugging and changes a 
do/while loop to a for loop to avoid hitting another delay each time.

Catherine fixes inconsistent MSI and MSI-X messages and bumps
the driver version.

Mitch Williams (12):
  i40evf: request reset on tx hang
  i40evf: remove VLAN filters on close
  i40evf: fix multiple crashes on remove
  i40evf: get rid of pci_using_dac
  i40evf: fix up strings in init task
  i40evf: remove bogus comment
  i40evf: don't guess device name
  i40evf: store ring size in ring structs
  i40evf: update version and copyright date
  i40evf: remove errant space
  i40e: remove unnecessary delay
  i40e: tighten up ring enable/disable flow

Catherine Sullivan (2):
  i40e: Change MSIX to MSI-X
  i40e and i40evf: Bump driver versions

 drivers/net/ethernet/intel/i40e/i40e_main.c        | 43 ++++++-----
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |  1 -
 .../net/ethernet/intel/i40evf/i40e_adminq_cmd.h    |  2 +-
 drivers/net/ethernet/intel/i40evf/i40evf.h         |  3 +-
 drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c | 13 ++--
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    | 85 +++++++++++-----------
 .../net/ethernet/intel/i40evf/i40evf_virtchnl.c    | 12 +++
 7 files changed, 85 insertions(+), 74 deletions(-)

-- 
1.8.5.GIT
