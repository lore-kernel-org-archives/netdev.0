From: Vlad Zolotarov <vladz@cloudius-systems.com>
Subject: [PATCH net-next v1 0/5]: ixgbevf: Allow querying VFs RSS indirection table and key
Date: Wed, 31 Dec 2014 11:51:54 +0200
Message-ID: <1420019519-18139-1-git-send-email-vladz@cloudius-systems.com>
Cc: gleb@cloudius-systems.com, avi@cloudius-systems.com,
	jeffrey.t.kirsher@intel.com,
	Vlad Zolotarov <vladz@cloudius-systems.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:32837 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750710AbaLaJwM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Dec 2014 04:52:12 -0500
Received: by mail-wi0-f177.google.com with SMTP id l15so25285505wiw.16
        for <netdev@vger.kernel.org>; Wed, 31 Dec 2014 01:52:10 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the ethtool ops to VF driver to allow querying the RSS indirection table
and RSS Random Key.
 
 - PF driver: Add new VF-PF channel commands.
 - VF driver: Utilize these new commands and add the corresponding
              ethtool callbacks.

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

 drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h      |   8 ++
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c    |  52 ++++++++++
 drivers/net/ethernet/intel/ixgbevf/ethtool.c      |  37 +++++++
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   4 +-
 drivers/net/ethernet/intel/ixgbevf/mbx.h          |   8 ++
 drivers/net/ethernet/intel/ixgbevf/vf.c           | 117 ++++++++++++++++++++++
 drivers/net/ethernet/intel/ixgbevf/vf.h           |   2 +
 7 files changed, 227 insertions(+), 1 deletion(-)

-- 
2.1.0
