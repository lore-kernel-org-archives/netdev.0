From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 00/14] Intel Wired LAN Driver Updates
Date: Fri,  1 Aug 2014 13:27:01 -0700
Message-ID: <1406924835-31550-1-git-send-email-aaron.f.brown@intel.com>
Cc: Aaron Brown <aaron.f.brown@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:60887 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755837AbaHAUXR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Aug 2014 16:23:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to the i40e and i40evf drivers.

Vasu adds FCOE support, build options and a documentation pointer to i40e.

Shannon exposes a Firmware API request used to do register writes on the
driver's behalf and disables local loopback on VMDQ VSI in order to stop the
VEB from echoing the VMDQ packets back at the VSI.

Ashish corrects the vf_id offset for virtchnl messages in the case of multiple
PFs, removes support for vf unicast promiscuos mode to disallow VFs from
receiving traffic intended for another VF, updates the vfr_stat state check to
handle the existing and future mechanism and adds an adapter state check to
prevent re-arming the watchdog timer after i40evf_remove has been called and
the timer has been deleted.

Serey fixes an issue where a guest OS would panic when removing the vf driver
while the device is being reset due to an attempt to clean a non initialized
mac_filter_list.

Akeem makes a minor comment change.

Jessie changes an instance of sprintf to snprintf that was missed when the
driver was converted to use snprintf everywhere.

Mitch plugs a few memory leaks.

Akeem G Abodunrin (1):
  i40e: Minor comment changes

Ashish Shah (4):
  i40e: use correct vf_id offset for virtchnl message
  i40e: remove support for vf unicast promiscuous mode
  i40evf: future-proof vfr_stat state check
  i40evf: do not re-arm watchdog after remove

Jesse Brandeburg (1):
  i40evf: fix scan warning on sprintf

Mitch Williams (2):
  i40evf: don't leak queue vectors
  i40evf: fix memory leak on unused interfaces

Serey Kong (1):
  i40evf: Fixed guest OS panic when removing vf driver

Shannon Nelson (2):
  i40e: expose debug_write_register request
  i40e: disable local loopback on vmdq vsi

Vasu Dev (3):
  i40e: adds FCoE code to the i40e driver
  i40e: Adds FCoE related code to i40e core driver
  i40e: adds FCoE to build and updates its documentation

 Documentation/networking/i40e.txt                  |    7 +-
 drivers/net/ethernet/intel/i40e/Makefile           |    1 +
 drivers/net/ethernet/intel/i40e/i40e.h             |   62 +
 drivers/net/ethernet/intel/i40e/i40e_common.c      |   56 +
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c     |   19 +
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |   35 +
 drivers/net/ethernet/intel/i40e/i40e_fcoe.c        | 1561 ++++++++++++++++++++
 drivers/net/ethernet/intel/i40e/i40e_fcoe.h        |  128 ++
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  269 +++-
 drivers/net/ethernet/intel/i40e/i40e_osdep.h       |    3 +
 drivers/net/ethernet/intel/i40e/i40e_prototype.h   |    6 +
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        |   37 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.h        |    9 +
 drivers/net/ethernet/intel/i40e/i40e_type.h        |  138 ++
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |   34 +-
 drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c |    2 +-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |   59 +-
 17 files changed, 2393 insertions(+), 33 deletions(-)
 create mode 100644 drivers/net/ethernet/intel/i40e/i40e_fcoe.c
 create mode 100644 drivers/net/ethernet/intel/i40e/i40e_fcoe.h

-- 
1.9.3
