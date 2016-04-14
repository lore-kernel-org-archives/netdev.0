From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 0/2][pull request] Intel Wired LAN Driver Updates 2016-04-13
Date: Wed, 13 Apr 2016 20:47:10 -0700
Message-ID: <1460605632-112945-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	john.ronciak@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:10479 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752362AbcDNDrP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2016 23:47:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e, i40evf and fm10k.

Alex fixes a bug introduced earlier based on his interpretation of the
XL710 datasheet.  The actual limit for fragments with TSO and a skbuff
that has payload data in the header portion of the buffer is actually
only 7 fragments and the skb-data portion counts as 2 buffers, one for
the TSO header, and the one for a segment payload buffer.

Jacob fixes a bug where in a previous refactor of the code broke
multi-bit updates for VFs.  The problem occurs because a multi-bit
request has a non-zero length, and the PF would simply drop any
request with the upper 16 bits set.

The following are changes since commit a6d37131c02f15463daa00e2f1da6824e8e00de2:
  net: ethernet: renesas: ravb_main: test clock rate to avoid division by 0
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-queue master

Alexander Duyck (1):
  i40e/i40evf: Limit TSO to 7 descriptors for payload instead of 8 per
    packet

Jacob Keller (1):
  fm10k: fix multi-bit VLAN update requests from VF

 drivers/net/ethernet/intel/fm10k/fm10k_pf.c   | 30 +++++++++++-----
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 49 +++++++++++++--------------
 drivers/net/ethernet/intel/i40e/i40e_txrx.h   | 10 ++++--
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 49 +++++++++++++--------------
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h | 10 ++++--
 5 files changed, 84 insertions(+), 64 deletions(-)

-- 
2.5.5
