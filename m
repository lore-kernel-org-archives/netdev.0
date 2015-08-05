From: Sathya Perla <sathya.perla@avagotech.com>
Subject: [PATCH 0/3] be2net: patch set
Date: Wed,  5 Aug 2015 03:27:47 -0400
Message-ID: <1438759670-2134-1-git-send-email-sathya.perla@avagotech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmrelayp1.emulex.com ([138.239.112.140]:56691 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751000AbbHEHVb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2015 03:21:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This patch set contains 2 driver fixes to a Lancer HW issue and a fix
to a double free bug. Pls apply to the "net" tree. Thanks!

Patch 1 now enables filters only after creating RXQs. This is done as 
HW issues were observed on Lancer adapters if filters
(flags, mac addrs etc) are enabled *before* creating RXQs. This patch
changes the driver design by enabling filters in be_open() --
instead of be_setup() -- after RXQs are created and buffers posted.

Patch 2 fixes an RX stall issue that was seen on Lancer adapters when
RXQs are destroyed while they are in an "out of buffer" state.
This patch fixes this issue by posting 64 buffers to each RXQ before
destroying them in the close path. This is done after ensuring that no
more new packets are selected for transfer to the RXQs by disabling
interface filters.

Patch 3 protects eqo->affinity_mask variable from being freed twice and
resulting in a crash.  It's now freed only when EQs haven't yet been
destroyed.

Kalesh AP (3):
  be2net: enable IFACE filters only after creating RXQs
  be2net: post buffers before destroying RXQs in Lancer
  be2net: protect eqo->affinity_mask from getting freed twice

 drivers/net/ethernet/emulex/benet/be_cmds.h |   5 +
 drivers/net/ethernet/emulex/benet/be_main.c | 187 ++++++++++++++++++----------
 2 files changed, 125 insertions(+), 67 deletions(-)

-- 
2.4.1
