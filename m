From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/15][pull request] 40GbE Intel Wired LAN Driver Updates 2016-04-26
Date: Tue, 26 Apr 2016 13:55:33 -0700
Message-ID: <1461704148-114349-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	john.ronciak@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:24352 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752428AbcDZUzv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Apr 2016 16:55:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf.

Alex Duyck cleans up the feature flags since they are becoming pretty
"massive", the primary change being that we now build our features list
around hw_encap_features.  Added support for IPIP and SIT offloads,
which should improvement in throughput for IPIP and SIT tunnels with
the offload enabled.

Mitch adds support for configuring RSS on behalf of the VFs, which removes
the burden of dealing with different hardware interfaces from the VF
drivers and improves future compatibility.  Fix to ensure that we do not
panic by checking that the vsi_res pointer is valid before dereferencing
it, after which we can drink beer and eat peanuts.

Shannon does come housekeeping in i40e_add_fdir_ethtool() in preparation
for more cloud filter work.  Added flexibility to the nvmupdate
facility by adding the ability to specify an AQ event opcode to wait on
after Exec_AQ request.

Kiran implements the feature to allow users to change input set mask for
flow director using side-band channel.

Michal adds device capability which defines if an update is available and
if a security check is needed during the update process.

Kamil just adds a device id to support X722 QSFP+ device.

Greg fixes an issue where a mirror rule ID may be zero, so do not return
invalid parameter when the user passes in a zero for a rule ID.  Adds
support to steer packets to VSIs by VLAN tag alone while being in
promiscuous mode for multicast and unicast MAC addresses.

Jesse fixes the driver from offloading the VLAN tag into the skb any
time there was a VLAN tag and the hardware stripping was enabled, to
making sure it is enabled before put_tag.

The following are changes since commit fab7b629a82da1b59620470d13152aff975239f6:
  Merge branch 'ila-csum-neutral'
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 40GbE

Alexander Duyck (2):
  i40e/i40evf: Clean up feature flags
  i40e/i40evf: Add support for IPIP and SIT offloads

Anjali Singhai Jain (2):
  i40e: Add VF promiscuous mode driver support
  i40evf: Add driver support for promiscuous mode

Greg Rose (2):
  i40e: Remove zero check
  i40e: Add promiscuous on VLAN support

Jesse Brandeburg (1):
  i40e/i40evf: Only offload VLAN tag if enabled

Kamil Krawczyk (1):
  i40e: Add DeviceID for X722 QSFP+

Kiran Patil (1):
  i40e: Allow user to change input set mask for flow director

Michal Kosiarz (1):
  i40e: Add device capability which defines if update is available

Mitch Williams (3):
  i40e: Add support for configuring VF RSS
  i40evf: Don't Panic
  i40evf: Allow PF driver to configure RSS

Shannon Nelson (2):
  i40e: Code cleanup in i40e_add_fdir_ethtool
  i40e: Specify AQ event opcode to wait for

 drivers/net/ethernet/intel/i40e/i40e.h             |   7 +
 drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h  |   1 +
 drivers/net/ethernet/intel/i40e/i40e_common.c      |  82 ++++-
 drivers/net/ethernet/intel/i40e/i40e_devids.h      |   1 +
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     | 128 ++++++-
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  98 ++---
 drivers/net/ethernet/intel/i40e/i40e_nvm.c         |  49 ++-
 drivers/net/ethernet/intel/i40e/i40e_prototype.h   |   8 +
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        |  29 +-
 drivers/net/ethernet/intel/i40e/i40e_type.h        |   6 +
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 346 +++++++++++++++++-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h |   2 +
 .../net/ethernet/intel/i40evf/i40e_adminq_cmd.h    |   1 +
 drivers/net/ethernet/intel/i40evf/i40e_common.c    |   1 +
 drivers/net/ethernet/intel/i40evf/i40e_devids.h    |   1 +
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      |  27 +-
 drivers/net/ethernet/intel/i40evf/i40e_type.h      |   6 +
 drivers/net/ethernet/intel/i40evf/i40evf.h         |  39 +-
 drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c | 121 +++----
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    | 395 ++++++++-------------
 .../net/ethernet/intel/i40evf/i40evf_virtchnl.c    | 130 +++++++
 21 files changed, 1070 insertions(+), 408 deletions(-)

-- 
2.5.5
