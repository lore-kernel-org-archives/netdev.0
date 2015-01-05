From: Vlad Zolotarov <vladz@cloudius-systems.com>
Subject: [PATCH net-next v4 0/5]: ixgbevf: Allow querying VFs RSS indirection table and key
Date: Mon,  5 Jan 2015 16:46:37 +0200
Message-ID: <1420469202-1847-1-git-send-email-vladz@cloudius-systems.com>
Cc: gleb@cloudius-systems.com, avi@cloudius-systems.com,
	jeffrey.t.kirsher@intel.com,
	Vlad Zolotarov <vladz@cloudius-systems.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f51.google.com ([74.125.82.51]:36168 "EHLO
	mail-wg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753804AbbAEOqu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2015 09:46:50 -0500
Received: by mail-wg0-f51.google.com with SMTP id x12so27670624wgg.10
        for <netdev@vger.kernel.org>; Mon, 05 Jan 2015 06:46:48 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the ethtool ops to VF driver to allow querying the RSS indirection table
and RSS Random Key.
 
 - PF driver: Add new VF-PF channel commands.
 - VF driver: Utilize these new commands and add the corresponding
              ethtool callbacks.

New in v4:
   - Forgot to run checkpatch on v3 and there were a few styling things to fix. ;)

New in v3:
   - Added a missing support for x550 devices.
   - Mask the indirection table values according to PSRTYPE[n].RQPL.
   - Minimized the number of added VF-PF commands.
 
New in v2:
   - Added a detailed description to patches 4 and 5.
 
New in v1 (compared to RFC):
   - Use "if-else" statement instead of a "switch-case" for a single option case.
     More specifically: in cases where the newly added API version is the only one
     allowed. We may consider using a "switch-case" back again when the list of
     allowed API versions in these specific places grows up.

Vlad Zolotarov (5):
  ixgbe: Add a RETA query command to VF-PF channel API
  ixgbevf: Add a RETA query code
  ixgbe: Add GET_RSS_KEY command to VF-PF channel commands set
  ixgbevf: Add RSS Key query code
  ixgbevf: Add the appropriate ethtool ops to query RSS indirection
    table and key

 drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h      |  10 ++
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c    |  90 +++++++++++++++
 drivers/net/ethernet/intel/ixgbevf/ethtool.c      |  42 +++++++
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   4 +-
 drivers/net/ethernet/intel/ixgbevf/mbx.h          |  10 ++
 drivers/net/ethernet/intel/ixgbevf/vf.c           | 132 ++++++++++++++++++++++
 drivers/net/ethernet/intel/ixgbevf/vf.h           |   2 +
 7 files changed, 289 insertions(+), 1 deletion(-)

-- 
2.1.0
