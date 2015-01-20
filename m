From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 0/7] be2net: patch set
Date: Tue, 20 Jan 2015 03:51:42 -0500
Message-ID: <1421743909-14716-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.emulex.com ([138.239.224.100]:42758 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750956AbbATIs7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 03:48:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David, as the below patch-set includes minor bug fixes and some
code re-org, pls consider applying it to the "net-next" tree. Thanks!

Patch 1 fixes a bit of code duplication involving interface object
creation code.

Patch 2 ensures that when a flow-control FW cmd fails, the adapter state
continues to reflect the old values. This allows for correct reporting
on subsequent ethtool "get".

Patch 3 returns proper error for link config change on BE3/Lancer

Patch 4 adds a kernel log message for FW boot error on Lancer

Patch 5 adds a function reset on Lancer as a part of the function init
sequence.

Patch 6 moves some FW-cmd definitions that belong in be_cmds.h, but
were placed in be_hw.h

Patch 7 resets the "bw_min" field while configuring "bw_max" needed
for TX rate limiting config.

Kalesh AP (6):
  be2net: move interface create code to a separate routine
  be2net: fix failure case in setting flow control
  be2net: fail VF link config change via ndo_set_vf_link_state() on
    BE3/Lancer
  be2net: add a log message for POST timeout in Lancer
  be2net: issue function reset cmd in resume path
  be2net: Fix TX rate limiting on Lancer/Skyhawk-R VFs

Vasundhara Volam (1):
  be2net: move definitions related to FW cmdsfrom be_hw.h to be_cmds.h

 drivers/net/ethernet/emulex/benet/be_cmds.c    |  20 ++-
 drivers/net/ethernet/emulex/benet/be_cmds.h    | 175 +++++++++++++++++++
 drivers/net/ethernet/emulex/benet/be_ethtool.c |  14 +-
 drivers/net/ethernet/emulex/benet/be_hw.h      | 223 -------------------------
 drivers/net/ethernet/emulex/benet/be_main.c    |  65 ++++---
 5 files changed, 236 insertions(+), 261 deletions(-)

-- 
2.2.0
