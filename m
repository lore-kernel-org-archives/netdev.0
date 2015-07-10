From: Sathya Perla <sathya.perla@avagotech.com>
Subject: [PATCH net-next 0/9] be2net: patch set
Date: Fri, 10 Jul 2015 05:32:42 -0400
Message-ID: <1436520771-11656-1-git-send-email-sathya.perla@avagotech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmrelayp1.emulex.com ([138.239.112.140]:56755 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753368AbbGJJ02 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jul 2015 05:26:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David, the following patch set has code cleanup patches, minor enhancements
and non-critical fixes. Pls consider applying to the net-next tree. Thanks!

Patch 1 removes duplicate code in be_setup_wol() routine making it simpler
and more readable.

Patch 2 fixes the the bridge mode return value for the ndo_bridge_getlink()
call. Instead of just relying on the SRIOV enabled state, the driver now
queries the FW, for the actual mode of bridge.

Patch 3 removes code for setting D0 power state as it's already done
in pci_enable_device()

Patch 4 fixes a bad return value in be_check_ufi_compatibility() routine
introduced by an earlier commit.

Patch 5 fixes a field in udp header being accessed while in network endian
format.

Patch 6 fixes the be_mcc_notify() routine to return an error status when
the FW/HW is in an error state.

Patch 7 fixes the be_cmd_rx_filter() routine to issue the RX_FILTER cmd
and not wait for a completion from the FW. If the FW/adapter
is in an error state, this change helps in not holding up the rtnl_lock
and keeping bottom halves disabled while the driver timesout waiting for
a response from the FW.

Patch 8 fixes the be_cmd_set_loopback() routine to issue the LOOPBACK cmd
and not wait for the FW completion while spin_lock_bh() is held on the
mcc_lock. As the cmd is always issued from ethtool in a process context,
it can sleep till the FW completion is received.

Patch 9 bumps up the driver version to 10.6.0.3

Kalesh Purayil (3):
  be2net: remove duplicate code in be_setup_wol()
  be2net: query FW to check if EVB is enabled
  be2net: remove redundant D0 power state set

Sathya Perla (1):
  be2net: bump up the driver version to 10.6.0.3

Suresh Reddy (3):
  be2net: return error status from be_mcc_notify()
  be2net: make the RX_FILTER command asynchronous
  be2net: make SET_LOOPBACK_MODE cmd asynchrounous

Vasundhara Volam (1):
  be2net: fix wrong return value in be_check_ufi_compatibility()

Venkat Duvvuru (1):
  be2net: convert dest field in udp-hdr to host-endian

 drivers/net/ethernet/emulex/benet/be.h         |  2 +-
 drivers/net/ethernet/emulex/benet/be_cmds.c    | 64 ++++++++++++++++++++------
 drivers/net/ethernet/emulex/benet/be_cmds.h    |  3 ++
 drivers/net/ethernet/emulex/benet/be_ethtool.c | 15 +++++-
 drivers/net/ethernet/emulex/benet/be_main.c    | 40 +++++++---------
 5 files changed, 82 insertions(+), 42 deletions(-)

-- 
2.4.1
