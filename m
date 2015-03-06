From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/6][pull request] Intel Wired LAN Driver Updates 2015-03-06
Date: Fri,  6 Mar 2015 03:06:00 -0800
Message-ID: <1425639966-6829-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:50981 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756048AbbCFLGK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Mar 2015 06:06:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to e1000, e1000e and igb.

Yanir provides updates to e1000e based on the patches provided by John
Linville.  First updates the code comment to better describe the changes
and the impact on the driver.  Second removed calls to ioremap/unmap for
i219 since this is only relevant to older hardware only.  Starting with
i219, the NVM will not be mapped to its one BAR but to a address region
in another bar.

Alex Duyck provides two fixes for igb, first fixes a compile warning
where a variable may be used uninitialized, so Alex initializes it.
Second fixes an issue where all of the pin register values were having
to be pushed onto the stack each time the function was called, so to
avoid this, Alex made them static const so that they should only need
to be allocated once and we can avoid all the instructions to get them
onto the stack.

Eliezer found an issue in e1000 where we needed to be calling
netif_carrier_off earlier in the down() to prevent the stack from 
queuing more packets to the interface.

Sabrina Dubroca resolved a potential race condition by adding a
dummy allocator.  There was a race condition between e1000_change_mtu()
cleanups and netpoll, when changing the MTU across jumbo sizes.

The following are changes since commit 23375a0fd549aa0a8c96b9f56a0b8120ae1389dd:
  ipv4: Fix unused variable warnings in fib_table_flush_external.
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Alexander Duyck (2):
  igb: Fix warning pin may be used uninitialized
  igb: Make arrays on stack static const to avoid reallocation

Eliezer Tamir (1):
  e1000: call netif_carrier_off early on down

Sabrina Dubroca (1):
  e1000: add dummy allocator to fix race condition between mtu change
    and netpoll

Yanir Lubetkin (2):
  e1000e: fix obscure comments
  e1000e: remove calls to ioremap/unmap for NVM addr

 drivers/net/ethernet/intel/e1000/e1000_main.c | 12 ++++++++++--
 drivers/net/ethernet/intel/e1000e/ich8lan.c   | 12 ++++++++----
 drivers/net/ethernet/intel/e1000e/netdev.c    |  8 +++++---
 drivers/net/ethernet/intel/igb/igb_ptp.c      | 26 +++++++++++++-------------
 4 files changed, 36 insertions(+), 22 deletions(-)

-- 
1.9.3
