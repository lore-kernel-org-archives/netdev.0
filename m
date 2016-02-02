From: Stefan Assmann <sassmann@kpanic.de>
Subject: [PATCH net-next 0/6] net/intel: call ndo_stop() instead of dev_close() when running offline selftest
Date: Tue,  2 Feb 2016 11:13:42 +0100
Message-ID: <1454408028-16986-1-git-send-email-sassmann@kpanic.de>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com, sassmann@kpanic.de
To: intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44274 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754507AbcBBKQW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Feb 2016 05:16:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Calling dev_close() causes IFF_UP to be cleared which will remove the
interfaces routes and some addresses. That's probably not what the user
intended when running the offline selftest. Besides this does not happen
if the interface is brought down before the test, so the current
behaviour is inconsistent.
Instead call the net_device_ops ndo_stop function directly and avoid
touching IFF_UP at all.

Tested this with igb, e1000e, ixgbe and i40e. All drivers now are able to
resume operation without restoring the IP address, gateway or such.

Stefan Assmann (6):
  i40e: call ndo_stop() instead of dev_close() when running offline
    selftest
  ixgbe: call ndo_stop() instead of dev_close() when running offline
    selftest
  ixgbevf: call ndo_stop() instead of dev_close() when running offline
    selftest
  igb: call ndo_stop() instead of dev_close() when running offline
    selftest
  e1000: call ndo_stop() instead of dev_close() when running offline
    selftest
  e1000e: call ndo_stop() instead of dev_close() when running offline
    selftest

 drivers/net/ethernet/intel/e1000/e1000.h          | 2 ++
 drivers/net/ethernet/intel/e1000/e1000_ethtool.c  | 4 ++--
 drivers/net/ethernet/intel/e1000/e1000_main.c     | 8 ++++----
 drivers/net/ethernet/intel/e1000e/e1000.h         | 2 ++
 drivers/net/ethernet/intel/e1000e/ethtool.c       | 4 ++--
 drivers/net/ethernet/intel/e1000e/netdev.c        | 4 ++--
 drivers/net/ethernet/intel/i40e/i40e.h            | 2 +-
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c    | 4 ++--
 drivers/net/ethernet/intel/i40e/i40e_main.c       | 4 ----
 drivers/net/ethernet/intel/igb/igb.h              | 2 ++
 drivers/net/ethernet/intel/igb/igb_ethtool.c      | 4 ++--
 drivers/net/ethernet/intel/igb/igb_main.c         | 8 ++++----
 drivers/net/ethernet/intel/ixgbe/ixgbe.h          | 2 ++
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c  | 4 ++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     | 4 ++--
 drivers/net/ethernet/intel/ixgbevf/ethtool.c      | 4 ++--
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      | 2 ++
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 4 ++--
 18 files changed, 37 insertions(+), 31 deletions(-)

-- 
2.5.0
