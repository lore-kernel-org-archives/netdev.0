From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next  00/14][pull request] Intel Wired LAN Driver Updates
Date: Fri, 18 Oct 2013 06:23:04 -0700
Message-ID: <1382102598-11343-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: a@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:60483 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754292Ab3JRNXk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Oct 2013 09:23:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e only.

Jesse provides 6 patches against i40e.  First is a patch to reduce
CPU utilization by reducing read-flush to read in the hot path.  Next
couple of patches resolve coverity issues reported by Hannes Frederic
Sowa <hannes@stressinduktion.org>.  Then Jesse refactored i40e to cleanup
functions which used cpu_to_xxx(foo) which caused a lot of line wrapping.

Mitch provides 2 i40e patches.  First fixes a panic when tx_rings[0]
are not allocated, his second patch corrects a math error when
assigning MSI-X vectors to VFs.  The vectors-per-vf value reported
by the hardware already conveniently reports one less than the actual
value.

Shannon provides 5 patches against i40e.  His first patch corrects a
number of little bugs in the error handling of irq setup, most of
which ended up panicing the kernel.  Next he fixes the overactive
IRQ issue seen in testing and allows the use of the legacy interrupt.
Shannon then provides a cleanup of the arguments declared at the
beginning of each function.  Then he provides a patch to make sure
that there are really rings and queues before trying to dump
information in them.  Lastly he simplifies the code by using an
already existing variable.

Catherine provides an i40e patch to bump the version.

The following are changes since commit 7cc7c5e54b7128195a1403747a63971c3c3f8e25:
  net: Delete trailing semi-colon from definition of netdev_WARN()
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Catherine Sullivan (1):
  i40e: Bump version

Jesse Brandeburg (6):
  i40e: do not flush after re-enabling interrupts
  i40e: debugfs fixups
  i40e: clamp debugfs nvm read command
  i40e: fix use of untrusted scalar value warning
  i40e: fix sign extension issue
  i40e: refactor fdir setup function

Mitch Williams (2):
  i40e: don't free nonexistent rings
  i40e: assign correct vector to VF

Shannon Nelson (5):
  i40e: fixup legacy interrupt handling
  i40e: tweaking icr0 handling for legacy irq
  i40e: reorder block declarations in debugfs
  i40e: check vsi ptrs before dumping them
  i40e: use pf_id for pf function id in qtx_ctl

 drivers/net/ethernet/intel/i40e/i40e.h             |   1 +
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c     | 135 ++++++++++++---------
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  50 ++++----
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        |  83 ++++++-------
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |   4 +-
 5 files changed, 146 insertions(+), 127 deletions(-)

-- 
1.8.3.1
