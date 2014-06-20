From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/13][pull request] Intel Wired LAN Driver Updates 2014-06-20
Date: Fri, 20 Jun 2014 00:49:35 -0700
Message-ID: <1403250588-14356-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:62062 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933971AbaFTHtw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jun 2014 03:49:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf.

Anjali provides an update to the registers to handle the updates from the
hardware.  Also provides a fix so that we do not try to access the rings
through the qvectors at the time of freeing the qvectors.

Jesse provides a workaround for some older NVM versions where the NVM
was not filling in the GLQF_HKEY register, so made sure that the
critical register is initialized.

Michal provides a fix to reset the head and tail on admin queue
initialization where head and tail are not reset by the hardware.

Neerav adds a helper routine that would wait for the Rx/Tx queue to reach
the enable or disable state that is requested.  Also provides a fix
to the debugfs command "lldp get remote" which was dumping the local
LLDPDU instead of the peer's LLDPDU.  Fixed a bug when all the Tx hang
recovery mechanisms have failed and the driver tries to bring down the
interface in the interrupt context.

Shannon provides a patch to clear the Virtual Ethernet Bridge (VEB) stats
when the PF stats are cleared.  Also cleans the service tasks so that
they do not run while a reset is in progress.

Mitch fixes an issue in i40evf_get_rxfh() where only fifteen registers
were being read instead of all sixteen.

Carolyn provides a change to the RSS configuration to set table size and
write to the hardware to confirm the RSS table size being used.

Kamil makes a change to the admin queue debug prints so that they will not
cause segmentation faults in some of our tool applications.

The following are changes since commit e0f802fbcaa3bffe4728e37a8fa1279b5d554173:
  tcp: move ir_mark initialization to tcp_openreq_init
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Anjali Singhai Jain (2):
  i40e/i40evf: i40e_register.h update
  i40e: Fix dangling ring pointers upon driver removal

Carolyn Wyborny (1):
  i40e/i40evf: Update RSS configuration

Catherine Sullivan (1):
  i40e/i40evf: Bump i40e to 0.4.13 and i40evf to 0.9.35

Jesse Brandeburg (1):
  i40e: workaround NVM GLQF_HKEY

Kamil Krawczyk (1):
  i40e/i40evf: modify debug prints to avoid seg faults

Michal Kosiarz (1):
  i40e/i40evf: Reset Head and Tail on AQ initialization

Mitch Williams (1):
  i40evf: fix off-by-one

Neerav Parikh (3):
  i40e: Helper routine for Rx/Tx queue enable/disable wait
  i40e: debugfs fix to dump remote LLDPDU
  i40e: Fix scheduling while atomic bug during NAPI

Shannon Nelson (2):
  i40e: clear VEB stats when pf stats are cleared
  i40e: keep service tasks out of reset process

 drivers/net/ethernet/intel/i40e/i40e.h             |    3 +
 drivers/net/ethernet/intel/i40e/i40e_adminq.c      |   36 +-
 drivers/net/ethernet/intel/i40e/i40e_common.c      |    7 +-
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c     |    2 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  209 +-
 drivers/net/ethernet/intel/i40e/i40e_register.h    | 5011 ++++++++------------
 drivers/net/ethernet/intel/i40e/i40e_type.h        |    6 +
 drivers/net/ethernet/intel/i40evf/i40e_adminq.c    |   36 +-
 drivers/net/ethernet/intel/i40evf/i40e_register.h  | 5011 ++++++++------------
 drivers/net/ethernet/intel/i40evf/i40e_type.h      |    6 +
 drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c |    4 +-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |    2 +-
 12 files changed, 3954 insertions(+), 6379 deletions(-)

-- 
1.9.3
