From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 00/10] be2net: patch set
Date: Mon,  4 May 2015 02:47:12 -0400
Message-ID: <1430722042-26449-1-git-send-email-sathya.perla@emulex.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmrelayp1.emulex.com ([138.239.112.140]:63199 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752298AbbEDG7y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 02:59:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,
The following patch set has two new feature additions, and a few
minor fixes and cleanups.
Pls consider applying to the net-next tree. Thanks.

Patch 1 adds support for the "spoofchk" knob for VFs.
When it is enabled, "spoof checking" is done for both MAC-address
and VLAN.

Patch 2 improves interrupt moderation on Skyhawk-R chip by using
the EQ-DB mechanism to set a "re-arm to interrupt" delay. Currently
interrupt moderation is adjusted by calculating and configuring an
EQ-delay every second. This is done via a FW-cmd. This patch uses
the EQ_DB facility to calculate and set the interrupt delay every 1ms.
This helps moderating interrupts better when the traffic is bursty.

Patch 3 adds L3/L4 error accounting to BE3 VFs, by passing L3/4 error
packets to the network stack.

Patch 4 adds an extra FW-cmd error value check in the driver to identify
an "out of vlan filters" scenario.

Patch 5 stops enabling pause by default as this setting fails in
some HW-configs where priority pause is enabled in FW. If the user
tries to do the same, an appropriate error is returned via ethtool.

Patch 6 posts the full RXQ in be_open() to prevent packet drops due to
bursty traffic when the interface is enabled.

Patch 7 refactors the be_check_ufi_compatibility() routine, that checks
to see if a UFI file meant for a lower rev of a chip is being flashed
on a higher rev, to make it simpler.

Patch 8 replaces the usage of !be_physfn() macro with be_virtfn()
that is already avialble in the driver.

Patch 9 updates the year in the copyright text to 2015.

Path 10 bumps up the driver version to 10.6.02. 

Kalesh AP (4):
  be2net: add support for spoofchk setting
  be2net: check for INSUFFICIENT_VLANS error
  be2net: don't enable PAUSE by default
  be2net: use be_virtfn() instead of !be_physfn()

Padmanabh Ratnakar (1):
  be2net: set interrupt moderation for Skyhawk-R using EQ-DB

Sathya Perla (1):
  be2net: update the driver version to 10.6.0.2

Somnath Kotur (1):
  be2net: receive pkts with L3, L4 errors on VFs

Suresh Reddy (1):
  be2net: post full RXQ on interface enable

Vasundhara Volam (2):
  be2net: simplify UFI compatibility checking
  be2net: update copyright year to 2015

 drivers/net/ethernet/emulex/benet/be.h         |   6 +-
 drivers/net/ethernet/emulex/benet/be_cmds.c    |  23 +-
 drivers/net/ethernet/emulex/benet/be_cmds.h    |  33 +--
 drivers/net/ethernet/emulex/benet/be_ethtool.c |  15 +-
 drivers/net/ethernet/emulex/benet/be_hw.h      |  14 +-
 drivers/net/ethernet/emulex/benet/be_main.c    | 296 +++++++++++++++----------
 drivers/net/ethernet/emulex/benet/be_roce.c    |   2 +-
 drivers/net/ethernet/emulex/benet/be_roce.h    |   2 +-
 8 files changed, 254 insertions(+), 137 deletions(-)

-- 
2.2.0
