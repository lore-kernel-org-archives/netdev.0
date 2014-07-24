From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/14][pull request] Intel Wired LAN Driver Updates 2014-07-24
Date: Thu, 24 Jul 2014 06:13:10 -0700
Message-ID: <1406207604-31653-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:36503 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758527AbaGXNOD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jul 2014 09:14:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to igb, ixgbe, i40e and i40evf.

Mark fixes a possible attempt to dereference a NULL pointer in ixgbe_pr=
obe().
Also changes some uses of strncpy to strlcpy when clearing is not neede=
d to
prevent information leakage.

Jacob fixes a bug in the misuse of the list_for_each macro to loop over
every entry in the bus_list.  Instead of attempting to loop over the li=
st
from a random entry point, go up to the bus and use the real list_head
entry point.  This prevents the possible read or write of unallocated o=
r
incorrectly addressed memory.  Then provides a patch to prevent the
display of the minimum link qualification check if we might be in a
virtual machine.  This check is incorrect and misleading in this case,
since we actually do not really know what the available bandwidth is.
To do so, we simply check whether each function on the bus matches our
device id.

Carolyn adds a check and prints the error cause register value when the
hardware detects a malformed packet to assist the user.

Toralf F=C3=B6rster fixes a format mismatch in i40e which was found usi=
ng
cppcheck.

Shannon adds nvmupdate support by implementing a state machine intended
to support the userland tool for updating the device eeprom.

Jesse fixes the extension header checksum logic for IPv6 in i40e and
i40evf.

Mitch reduces a delay in the i40evf driver where we do not need to
delay an entire millisecond to get into our critical section.

Kamil fixes an issue where access to the NVM was being blocked until
a driver reset where a check for NVM related admin queue commands
would not recognize that such a command was received and would not clea=
r
nvm_busy flag.

Catherine fixes a couple of firmware API version errors.

The following are changes since commit f6e675324481c56b358091ddb446b2c9=
5a8e047b:
  Merge branch 'filter-move'
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next maste=
r

Carolyn Wyborny (1):
  igb: Add message when malformed packets detected by hw

Catherine Sullivan (2):
  i40e: Fix firmware API version errors
  i40e: Give link more time after setting flow control

Jacob Keller (2):
  ixgbe: fix use of list_for_each in ixgbe_enumerate_functions
  ixgbe: don't check minimum link when direct assigned to virtual
    machine

Jesse Brandeburg (1):
  i40e/i40evf: fix extension header csum logic

Kamil Krawczyk (1):
  i40e/i40evf: ARQ copy desc data even for failed commands

Mark Rustad (2):
  ixgbe: Fix possible null-dereference in error path
  ixgbe: Change some uses of strncpy to strlcpy

Mitch Williams (1):
  i40evf: don't wait so long

Shannon Nelson (2):
  i40e/i40evf: Add nvmupdate support
  i40e: always print aqtx answer

Todd Fujinaka (1):
  igb: bump igb version to 5.2.13

Toralf F=C3=B6rster (1):
  i40e: fix format mismatch in
    drivers/net/ethernet/intel/i40e/i40e_debugfs.c

 drivers/net/ethernet/intel/i40e/i40e_adminq.c    |  41 +-
 drivers/net/ethernet/intel/i40e/i40e_adminq.h    |  36 ++
 drivers/net/ethernet/intel/i40e/i40e_common.c    |  88 ++++
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c   |   4 +-
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c   |  71 +++-
 drivers/net/ethernet/intel/i40e/i40e_main.c      |  20 +-
 drivers/net/ethernet/intel/i40e/i40e_nvm.c       | 511 +++++++++++++++=
++++++++
 drivers/net/ethernet/intel/i40e/i40e_prototype.h |   7 +
 drivers/net/ethernet/intel/i40e/i40e_txrx.c      |   2 -
 drivers/net/ethernet/intel/i40e/i40e_type.h      |  58 +++
 drivers/net/ethernet/intel/i40evf/i40e_adminq.c  |  28 +-
 drivers/net/ethernet/intel/i40evf/i40e_adminq.h  |  36 ++
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c    |   2 -
 drivers/net/ethernet/intel/i40evf/i40e_type.h    |  58 +++
 drivers/net/ethernet/intel/i40evf/i40evf_main.c  |   4 +-
 drivers/net/ethernet/intel/igb/e1000_regs.h      |   1 +
 drivers/net/ethernet/intel/igb/igb_main.c        |  29 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |  42 +-
 18 files changed, 958 insertions(+), 80 deletions(-)

--=20
1.9.3
