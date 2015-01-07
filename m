From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net v2 0/3][pull request] Intel Wired LAN Driver Updates 2015-01-06
Date: Tue,  6 Jan 2015 17:31:54 -0800
Message-ID: <1420594317-6191-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:43205 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752268AbbAGBcE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2015 20:32:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains fixes to i40e only.

Jesse provides a fix for when the driver was polling with interrupts
disabled the hardware would occasionally not write back descriptors.
His fix causes the driver to detect this situation and force an interrupt
to fire which will flush the stuck descriptor.

Anjali provides a couple of fixes, the first corrects an issue where
the receive port checksum error counter was incrementing incorrectly with
UDP encapsulated tunneled traffic.  The second fix resolves an issue where
the driver was examining the outer protocol layer to set the inner protocol
layer checksum offload.  In the case of TCP over IPv6 over an IPv4 based
VXLAN, the inner checksum offloads would be set to look for IPv4/UDP
instead of IPv6/TCP, so fixed the issue so that the driver will look at
the proper layer for encapsulation offload settings.

v2: fixed a bug in patch 01 of the series, where the interrupt rate impacted
    4 port workloads by reducing throughput.

The following are changes since commit 2abad79afa700e837cb4feed170141292e0720c0:
  qla3xxx: don't allow never end busy loop
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net master

Anjali Singhai (2):
  i40e: Fix Rx checksum error counter
  i40e: Fix bug with TCP over IPv6 over VXLAN

Jesse Brandeburg (1):
  i40e: fix un-necessary Tx hangs

 drivers/net/ethernet/intel/i40e/i40e_txrx.c | 104 +++++++++++++++++++---------
 drivers/net/ethernet/intel/i40e/i40e_txrx.h |   1 +
 2 files changed, 73 insertions(+), 32 deletions(-)

-- 
1.9.3
