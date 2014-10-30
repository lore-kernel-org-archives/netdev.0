From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 0/4][pull request] Intel Wired LAN Driver Updates 2014-10-30
Date: Thu, 30 Oct 2014 05:33:52 -0700
Message-ID: <1414672436-20616-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:7296 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759052AbaJ3Md6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Oct 2014 08:33:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to e1000, igb and ixgbe.

Francesco Ruggeri fixes an issue with e1000 where in a VM the driver did
not support unicast filtering.

Roman Gushchin fixes an issue with igb where the driver was re-using
mapped pages so that packets were still getting dropped even if all
the memory issues are gone and there is free memory.

Junwei Zhang found where in the ixgbe_clean_rx_ring() we were repeating
the assignment of NULL to the receive buffer skb and fixes it.

Emil fixes a race condition between setup_link and SFP detection routine
in the watchdog when setting the advertised speed.

The following are changes since commit d70127e8a942364de8dd140fe73893efda363293:
  inet: frags: remove the WARN_ON from inet_evict_bucket
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net master

Emil Tantilov (1):
  ixgbe: fix race when setting advertised speed

Francesco Ruggeri (1):
  e1000: unset IFF_UNICAST_FLT on WMware 82545EM

Junwei Zhang (1):
  ixgbe: need not repeat init skb with NULL

Roman Gushchin (1):
  igb: don't reuse pages with pfmemalloc flag

 drivers/net/ethernet/intel/e1000/e1000_main.c    | 5 ++++-
 drivers/net/ethernet/intel/igb/igb_main.c        | 6 +++++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 4 ++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    | 2 +-
 4 files changed, 14 insertions(+), 3 deletions(-)

-- 
1.9.3
