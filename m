From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/9][pull request] 10GbE Intel Wired LAN Driver Updates 2015-12-24
Date: Thu, 24 Dec 2015 21:29:47 -0800
Message-ID: <1451021396-68858-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	john.ronciak@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:55539 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752491AbbLYF36 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Dec 2015 00:29:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to ixgbe and ixgbevf.

William Dauchy provides a fix for ixgbevf that was implemented for ixgbe,
commit 5d6002b7b822c7 ("ixgbe: Fix handling of NAPI budget when multiple
queues are enabled per vector"). The issue was that the polling routine
would increase the budget for receive to at least 1 per queue if multiple
queues were present, which resulted in receive packets being processed
when the budget was 0.

Emil provides minor cleanups for ixgbevf, one being that we need to
check rx_itr_setting with == and not &, since it is not a mask.  Added
QSFP PHY support in ixgbe to allow for more accurate reporting of port
settings.  Fixed the max RSS limit for X550 which is 63, not 64.  Lastly,
fix an issue which was causing PCI AER errors, by fixing the write to
the VLVFR register in ixgbe_clear_vf_vlans() where the word argument
is the actual offset of the register and not the index for the
IXGBE_VLVFB() macro.

Veola fixes ixgbe ethtool reporting of backplane type interfaces as
1000/10000baseT link modes, instead, report the media as KR, KX or KX4
based on the backplane interface present.

Mark cleans up redundancy in the setting of hw_enc_features that makes
it appear that X550 has more encapsulation features than other devices.
Also do not set NETIF_F_SG any longer since that is set by the
register_netdev() call.  Also fixed the X550EM_x revision check, which
needs to check a value, not just a bit.

Alex Duyck fixes additional bugs in ixgbe_clear_vf_vlans(), one being
that the mask was using a divide instead of a modulus, which resulted
in the mask bit being incorrectly set to 0 or 1 based on the value of
the VF being tested.  Alex also found that he was not consistent in
using the "word" argument as an offset or as a register offset, so
made the code consistently use word as the offset in the array.

The following are changes since commit d7d3e25f40e950bdcec6d94faf9346b7a7d6e4bb:
  cxgb4: Remove deprecated module parameters
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 10GbE

Alexander Duyck (1):
  ixgbe: Fix bugs in ixgbe_clear_vf_vlans()

Emil Tantilov (4):
  ixgbevf: minor cleanups for ixgbevf_set_itr()
  ixgbe: add support for QSFP PHY types in ixgbe_get_settings()
  ixgbe: fix RSS limit for X550
  ixgbe: fix write to VLVFB in ixgbe_clear_vf_vlans()

Mark Rustad (2):
  ixgbe: Clean up redundancy in hw_enc_features
  ixgbe: Correct X550EM_x revision check

Veola Nazareth (1):
  ixgbe: report correct media type for KR, KX and KX4 interfaces

William Dauchy (1):
  ixgbevf: Fix handling of NAPI budget when multiple queues are enabled
    per vector

 drivers/net/ethernet/intel/ixgbe/ixgbe.h          |  2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c  | 59 ++++++++++++++++++-----
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |  7 +--
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c    | 10 ++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h     |  2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_x550.c     |  9 ++--
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |  7 ++-
 7 files changed, 63 insertions(+), 33 deletions(-)

-- 
2.5.0
