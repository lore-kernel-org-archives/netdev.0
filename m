From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/15][pull request] Intel Wired LAN Driver Updates 2015-02-24
Date: Wed, 25 Feb 2015 00:58:25 -0800
Message-ID: <1424854720-18825-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:20292 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751293AbbBYI6o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Feb 2015 03:58:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf only, which bumps their
versions to i40e 1.2.9 and i40evf 1.2.3.

Paul fixes i40e_debug_aq() for big endian machines by adding the
appropriate LExx_TO_CPU wrappers.

Catherine adds a requested speed variable to the link_status to store the
last speeds we requested from the firmware and use the advertised speed
settings in get_settings in ethtool now that we have it.  Due to the
new code addition, she also refactors get_settings to improve readability
and to accommodate some of the longer lines of code by adding two
functions i40e_get_settings_link_up() and i40e_get_settings_link_down().

Carolyn adds a struct to the VSI struct to keep track of RXNFC settings
done via ethtool.  Adds more information to the interrupt vector
names, specifically to the VF misc vector name so that we can distinguish
between all the interrupts.

Ashish enables the i40evf driver to enable debug prints via ethtool.

Mitch updates i40e to enable packet split only when IOMMU is in use,
since it shows a distinct advantage over the single-buffer path
because it minimizes DMA mapping and unmapping.  Also adds the receive
routine in use to the features log message to be able to print the
receive packet split status.

Greg adds the ability to get, set and commit permanently the NPAR
partition BW configuration through configfs.  Enables an application
to query the i40e driver's private flags to get the status of NPAR
enablement via ethtool.

Neerav adds support for bridge offload ndo_ops getlink and setlink
to enable bridge hardware mode as per the mode set via IFLA_BRIDGE_MODE.
The support is only enabled in the case of a PF VSI and not available for
any other VSI type.

Kevin fixes i40e by ensuring the BUF and FLAG_RD flags are set for
indirect admin queue command.

Vasu updates the driver to setup FCoE netdev device type as "fcoe", so that
it shows up in sysfs as FCoE device.

The following are changes since commit 92bf200881d978bc3c6a290991ae1f9ddc7b5411:
  net: via-rhine: add BQL support
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Ashish Shah (1):
  i40evf: allow enabling of debug prints via ethtool

Carolyn Wyborny (2):
  i40e: Add method to keep track of current rxnfc settings
  i40evf: Add more info to interrupt vector names

Catherine Sullivan (1):
  i40e/i40evf: Use advertised speed settings in ethtool and refactor
    get_settings

Greg Rose (3):
  i40e: Add NPAR BW get and set functions
  i40e: Implement configfs for NPAR BW configuration
  i40e: Use ethtool private flags to display NPAR status

Kevin Scott (2):
  i40e: Set BUF flag for Set Version AQ command
  i40e: Set FLAG_RD when sending buffer FW must read

Mitch Williams (2):
  i40e: enable packet split only when IOMMU present
  i40e: print Rx packet split status

Neerav Parikh (1):
  i40e: Add support for getlink, setlink ndo ops

Paul M Stillwell Jr (1):
  i40e/i40evf: Fix output of i40e_debug_aq() for big endian machines

Sravanthi Tangeda (1):
  i40e/i40evf: Update driver versions

Vasu Dev (1):
  i40e: setup FCoE device type

 drivers/net/ethernet/intel/i40e/Makefile           |   3 +-
 drivers/net/ethernet/intel/i40e/i40e.h             |  24 +-
 drivers/net/ethernet/intel/i40e/i40e_common.c      | 150 ++++++++-
 drivers/net/ethernet/intel/i40e/i40e_configfs.c    | 354 ++++++++++++++++++++
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c     |   5 +-
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     | 330 ++++++++++++-------
 drivers/net/ethernet/intel/i40e/i40e_fcoe.c        |  18 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 358 +++++++++++++++++++--
 drivers/net/ethernet/intel/i40e/i40e_prototype.h   |   8 +-
 drivers/net/ethernet/intel/i40e/i40e_type.h        |  16 +-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |   5 +-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h |   3 +-
 drivers/net/ethernet/intel/i40evf/i40e_common.c    |  29 +-
 drivers/net/ethernet/intel/i40evf/i40e_type.h      |   3 +-
 drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c |   6 +-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |   7 +-
 16 files changed, 1130 insertions(+), 189 deletions(-)
 create mode 100644 drivers/net/ethernet/intel/i40e/i40e_configfs.c

-- 
1.9.3
