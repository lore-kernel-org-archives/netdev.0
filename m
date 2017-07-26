From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/14][pull request] 40GbE Intel Wired LAN Driver Updates 2017-07-25
Date: Wed, 26 Jul 2017 03:31:09 -0700
Message-ID: <20170726103123.76743-1-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:17153 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751615AbdGZKbp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 26 Jul 2017 06:31:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e and i40evf only.

Gustavo Silva fixes a variable assignment, where the incorrect variable
was being used to store the error parameter.

Carolyn provides a fix for a problem found in systems when entering S4
state, by ensuring that the misc vector's IRQ is disabled as well.

Jake removes the single-threaded restriction on the module workqueue,
which was causing issues with events such as CORER.  Does some future
proofing, by changing how the driver displays the UDP tunnel type.

Paul adds a retry in releasing resources if the admin queue times out
during the first attempt to release the resources.

Jesse fixes up references to 32bit timspec, since there are a small set
of errors on 32 bit, so we need to be using the right calls for dealing
with timespec64 variables.  Cleaned up code indentation and corrected
an "if" conditional check, as well as making the code flow more clear.
Cast or changed the types to remove warnings for comparing signed and
unsigned types.  Adds missing includes in i40evf, which were being used
but were not being directly included.

Daniel Borkmann fixes i40e to fill the XDP prog_id with the id just like
other XDP enabled drivers, so that on dump we can retrieve the attached
program based on the id and dump BPF insns, opcodes, etc back to user
space.

Tushar Dave adds le32_to_cpu while evaluating the hardware descriptor
fields, since they are in little-endian format.  Also removed
unnecessary "__packed" to a couple of i40evf structures.

Stefan Assmann fixes an issue when an administratively set MAC was set
and should now be switched back to 00:00:00:00:00:00, the pf_set_mac
flag is not being toggled back to false.

The following are changes since commit 34c8c10a766c8daf42293664f5c9ca5516fa3f41:
  Merge branch 'bnxt_en-Fix-kbuild-errors-and-rename-phys_port_name'
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 40GbE

Carolyn Wyborny (1):
  i40e: Fix for trace found with S4 state

Daniel Borkmann (1):
  i40e: report BPF prog id during XDP_QUERY_PROG

Gustavo A R Silva (1):
  i40e: fix incorrect variable assignment

Jacob Keller (2):
  i40e: remove WQ_UNBOUND and the task limit of our workqueue
  i40e: display correct UDP tunnel type name

Jesse Brandeburg (5):
  i40e: fix up 32 bit timespec references
  i40e: fix odd formatting and indent
  i40e/i40evf: make IPv6 ATR code clearer
  i40e/i40evf: remove mismatched type warnings
  i40evf: add some missing includes

Paul M Stillwell Jr (1):
  i40e: Handle admin Q timeout when releasing NVM

Stefan Assmann (1):
  i40e: handle setting administratively set MAC address back to zero

Tushar Dave (2):
  i40evf: Use le32_to_cpu before evaluating HW desc fields
  i40evf: remove unnecessary __packed

 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |  6 +--
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 57 ++++++++++++++++------
 drivers/net/ethernet/intel/i40e/i40e_nvm.c         | 21 +++++++-
 drivers/net/ethernet/intel/i40e/i40e_ptp.c         |  5 +-
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        | 18 ++++---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 32 +++++++-----
 drivers/net/ethernet/intel/i40evf/i40e_osdep.h     |  4 +-
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      |  6 +--
 drivers/net/ethernet/intel/i40evf/i40evf.h         | 11 +++++
 drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c |  4 +-
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    | 14 +++---
 11 files changed, 122 insertions(+), 56 deletions(-)

-- 
2.13.3
