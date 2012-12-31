From: Andreas Mohr <andi@lisas.de>
Subject: [PATCH RFC 00/15] via-rhine: fix resume, cleanup, eth ops (regs)
Date: Mon, 31 Dec 2012 16:25:34 +0100
Message-ID: <1356967549-5056-1-git-send-email-andi@lisas.de>
Cc: Roger Luethi <rl@hellgate.ch>, netdev@vger.kernel.org,
	Francois Romieu <romieu@fr.zoreil.com>
To: andim2@users.sf.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhlx01.hs-esslingen.de ([129.143.116.10]:54152 "EHLO
	rhlx01.hs-esslingen.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751414Ab2LaPep (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2012 10:34:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Mohr <andim2@users.sf.net>

This patchset fixes suspend/resume of via-rhine in the NetworkManager case
(patch 0001), with subsequent patches being predominantly
about general cleanup/renovation work
(one patch adds get_regs() ethtool support, though).

Currently marked as RFC since it's somewhat larger,
without prior review activity.

checkpatch.pl'd patchset against a slightly oldish master
(current state of via-rhine.c in linux-next is identical).

Note that some parts in this patchset have a dependency on predecessors
(e.g. __read_mostly comes to mind).

I managed to stay at 15 patches, thus right at (below) the
official mailing list patch limit.

Somehow Christmas must have been mighty boring :)

And one of the patches narrows down on non-default
compiler warning levels, too (c.f. my recent LKML tirade).

The first patch (resume fix) possibly is -stable material,
but since layer separation currently is not crystal clear
there might be some risk, thus I'm hesitating.

Thanks!


Andreas Mohr (15):
  via-rhine: YARB: fix broken resume of ifdown case (NetworkManager).
  via-rhine: some suspend/resume cleanup.
  via-rhine: small rhine_wait_bit() improvement.
  via-rhine: handle compile warnings (use PCI_VDEVICE macro).
  via-rhine: Spelling/phrases cleanup.
  via-rhine: The Great Renaming.
  via-rhine: MMIO: move register verify into helper function.
  via-rhine: MMIO: move support decision (compile-time-only to
    runtime).
  via-rhine: mark some variables as __read_mostly.
  via-rhine: WOL: remove duplication into a helper.
  via-rhine: WOL: separate WOL configuration (and its logging).
  via-rhine: implement get_regs() ethtool ops.
  via-rhine: misc. cleanup.
  via-rhine: The Great Deduplication.
  via-rhine: add helper (reduce type-unsafe void * assignments).

 drivers/net/ethernet/via/via-rhine.c |  572 +++++++++++++++++++++++-----------
 1 files changed, 396 insertions(+), 176 deletions(-)

-- 
1.7.2.5
