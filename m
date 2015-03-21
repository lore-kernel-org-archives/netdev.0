From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/5][pull request] Intel Wired LAN Driver Updates 2015-03-20
Date: Fri, 20 Mar 2015 17:57:40 -0700
Message-ID: <1426899465-15789-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:50519 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752911AbbCUA56 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Mar 2015 20:57:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ixgb, e1000e, igb and igbvf.

Eliezer and Todd provide patches to fix a potential issue found during code
inspection.  When bringing down an interface netif_carrier_off() should
be one of the first things we do, since this will prevent the stack from
queueing more packets to this interface.

Yanir provides a fix for e1000e that was found in validating i219,
where the call to e1000e_write_protect_nvm_ich8lan() is no longer
supported in newer hardware.  Access to these registers causes a
system freeze in early steppings and is ignored in later steppings.

The following are changes since commit f6877fcf229b4e3d396cbd5199e040b4ea1362eb:
  Merge branch 'ebpf-next'
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue master

master

Eliezer Tamir (2):
  ixgb: call netif_carrier_off early on down
  e1000e: call netif_carrier_off early on down

Todd Fujinaka (2):
  igb: use netif_carrier_off earlier when bringing if down
  igbvf: use netif_carrier_off earlier when bringing if down

Yanir Lubetkin (1):
  e1000e: NVM write protect access removed from SPT HW

 drivers/net/ethernet/intel/e1000e/netdev.c  | 7 ++++---
 drivers/net/ethernet/intel/igb/igb_main.c   | 4 +---
 drivers/net/ethernet/intel/igbvf/netdev.c   | 3 +--
 drivers/net/ethernet/intel/ixgb/ixgb_main.c | 3 ++-
 4 files changed, 8 insertions(+), 9 deletions(-)

-- 
1.9.3
