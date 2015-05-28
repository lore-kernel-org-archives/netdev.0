From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/14][pull request] Intel Wired LAN Driver Updates 2015-05-28
Date: Thu, 28 May 2015 04:25:25 -0700
Message-ID: <1432812339-17129-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:4939 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753660AbbE1LZl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 May 2015 07:25:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ethtool, ixgbe, i40e and i40evf.

John adds helper routines for ethtool to pass VF to rx_flow_spec.  Since
the ring_cookie is 64 bits wide which is much larger than what could be
used for actual queue index values, provide helper routines to pack a VF
index into the cookie.  Then John provides a ixgbe patch to allow flow
director to use the entire queue space.

Neerav provides a i40e patch to collect XOFF Rx stats, where it was not
being collected before.

Anjali provides ATR support for tunneled packets, as well as stats to
count tunnel ATR hits.  Cleaned up PF struct members which are
unnecessary, since we can use the stat index macro directly.  Cleaned
up flow director ATR/SB messages to a higher debug level since they
are not useful unless silicon validation is happening.

Greg provides a patch to disable offline diagnostics if VFs are enabled
since ethtool offline diagnostic tests are not designed (out of scope)
to disable VF functions for testing and re-enable afterward.  Also cleans
up TODO comment that is no longer needed.

Vasu provides a fix an FCoE EOF case where i40e_fcoe_ctxt_eof() maybe
called before i40e_fcoe_eof_is_supported() is called.

Jesse adds skb->xmit_more support for i40evf.  Then provides a performance
enhancement for i40evf by inlining some functions which provides a 15%
gain in small packet performance.  Also cleans up the use of time_stamp
since it is no longer used to determine if there is a tx_hang and was
a part of a previous tx_hang design which is no longer used.

The following are changes since commit ed2dfd900992aa7b6b3d0abd8ec9a7e9d2c7f827:
  tcp/dccp: warn user for preferred ip_local_port_range
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue master

Anjali Singhai Jain (4):
  i40e/i40evf: Add ATR support for tunneled TCP/IPv4/IPv6 packets.
  i40e/i40evf: Add stats to count Tunnel ATR hits
  i40e: Remove unnecessary pf members
  i40e: Move the FD ATR/SB messages to a higher debug level

Catherine Sullivan (1):
  i40e: Bump version to 1.3.4

Greg Rose (2):
  i40e: Disable offline diagnostics if VFs are enabled
  i40e/i40evf: Remove unneeded TODO

Jesse Brandeburg (3):
  i40evf: skb->xmit_more support
  i40e/i40evf: force inline transmit functions
  i40e/i40evf: remove time_stamp member

John Fastabend (2):
  ethtool: Add helper routines to pass vf to rx_flow_spec
  ixgbe: Allow flow director to use entire queue space

Neerav Parikh (1):
  i40e: Collect PFC XOFF RX stats even in single TC case

Vasu Dev (1):
  i40e: fix unrecognized FCOE EOF case

 drivers/net/ethernet/intel/i40e/i40e.h             |   5 +-
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |  30 +++-
 drivers/net/ethernet/intel/i40e/i40e_fcoe.c        |  11 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  39 ++---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        | 144 ++++++++++---------
 drivers/net/ethernet/intel/i40e/i40e_txrx.h        |   2 +-
 drivers/net/ethernet/intel/i40e/i40e_type.h        |   1 +
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |   7 +
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      | 158 ++++++++++-----------
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h      |   2 +-
 drivers/net/ethernet/intel/i40evf/i40e_type.h      |   1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c   |  34 +++--
 include/uapi/linux/ethtool.h                       |  25 ++++
 13 files changed, 272 insertions(+), 187 deletions(-)

-- 
2.1.0
