From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/15][pull request] Intel Wired LAN Driver Updates 2014-06-08
Date: Sun,  8 Jun 2014 07:33:42 -0700
Message-ID: <1402238037-20661-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:64912 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753301AbaFHOeB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Jun 2014 10:34:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf.

Jesse fixes an issue reported by Eric Dumazet where the driver was not
masking the right bits in the receive descriptor before checking them.
Also fixes TSO accounting since the kernel now can send as much as 32kB
in a single skb->frag[.] entry, even on a system with 4kB pages.

Anjali cleans up registers which are no longer supported.

Akeem cleans up code comments and removes num_msix_entries from the
interrupt setup routine since it was not being used.  Fixes an issue where
FD SB/ATR and NTUPLE configuration status were reported erroneously, so
now the driver reports FDir without further information.  Fixes a coding
error where during the registration for NAPI, the driver was requesting
256 budget.  The max recommended value for this NAPI_POLL_WEIGHT or 64.
Lastly, removed deprecated device IDs because they will not be shipped.

Mitch removes log messages which were redundant so therefore unnecessary.
Also removes a bogus code comment since VF drivers require MSI-X or they
won't get interrupts at all and cleans up the formatting of several log
messages.  Mitch also fixes the possibility of null pointers in VSI, since
not all VSIs have transmit rings.

Shannon ensures to clear the PXE mode bit on each reset after the AdminQ
has been rebuilt.

Catherine bumps the driver versions for i40e and i40evf.

The following are changes since commit fff1f59b1773fcbb563c503ad9c7ace54062144b:
  mac802154: llsec: add forgotten list_del_rcu in key removal
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Akeem G Abodunrin (2):
  i40e/i40evf: Clean up a few things
  i40e: Fix incorrect feature configuration status

Anjali Singhai Jain (1):
  i40e/i40evf: Fix code to accommodate i40e_register.h changes

Catherine Sullivan (1):
  i40e/i40evf: Bump build version

Jesse Brandeburg (4):
  i40e/i40evf: fix rx descriptor status
  i40e/i40evf: fix TSO accounting
  i40e/i40evf: fix poll weight
  i40e/i40evf: remove deprecated device IDs

Mitch Williams (6):
  i40evf: remove unnecessary log messages
  i40evf: remove bogus comment
  i40evf: clean up log message formatting
  i40evf: use correct format for printing MAC addresses
  i40e: not all VSIs have rings
  i40e/i40evf: remove chatty reset messages

Shannon Nelson (1):
  i40e: clear pxe after adminq is rebuilt

 drivers/net/ethernet/intel/i40e/i40e.h             |  1 -
 drivers/net/ethernet/intel/i40e/i40e_common.c      | 11 +----
 drivers/net/ethernet/intel/i40e/i40e_hmc.c         |  7 +--
 drivers/net/ethernet/intel/i40e/i40e_hmc.h         |  7 +--
 drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c     | 11 ++---
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 24 ++++------
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        |  7 +--
 drivers/net/ethernet/intel/i40e/i40e_txrx.h        |  4 +-
 drivers/net/ethernet/intel/i40e/i40e_type.h        | 12 ++---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl.h    |  4 --
 drivers/net/ethernet/intel/i40evf/i40e_common.c    |  2 -
 drivers/net/ethernet/intel/i40evf/i40e_hmc.h       |  7 +--
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      |  7 +--
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h      |  4 +-
 drivers/net/ethernet/intel/i40evf/i40e_type.h      | 14 +++---
 drivers/net/ethernet/intel/i40evf/i40e_virtchnl.h  |  4 --
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    | 55 ++++++++--------------
 .../net/ethernet/intel/i40evf/i40evf_virtchnl.c    | 49 +++++++------------
 18 files changed, 74 insertions(+), 156 deletions(-)

-- 
1.9.3
