From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [PATCH net-next v2 0/7] ieee802.15.4 general fixes
Date: Wed, 11 Jul 2012 11:22:41 +0400
Message-ID: <1341991368-11800-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:32780 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754158Ab2GKH0u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2012 03:26:50 -0400
Received: by wgbdr13 with SMTP id dr13so745049wgb.1
        for <netdev@vger.kernel.org>; Wed, 11 Jul 2012 00:26:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear David, Eric,

this patch-set is mostly intended to fix sparse and LOCKDEP warnings.
It mostly contains some my previous patches reworked and extended according
to the hints from Eric Dumazet and Fengguang Wu. Many thanks to they!

Changes since v1:
1. A new patch from Tony Cheneau was added. The fragmentation stops working
after some amount of packets sent. This patch fixes this issue.
2. 6lowpan fragment deleting routine: I removed spinlocks from timer_expired
handler and use spin_lock_bh to disable concurrency races with timer interrupt.
3. at86rf230 irq handler was a little bit modified

With best regards,
Alex

Alexander Smirnov (7):
  6lowpan: revert: add missing spin_lock_init()
  drivers/ieee802154/at86rf230: rework irq handler
  mac802154: add get short address method
  6lowpan: get extra headroom in allocated frame
  mac802154: sparse warnings: make symbols static
  6lowpan: fix tag variable size
  6lowpan: rework fragment-deleting routine

 drivers/ieee802154/at86rf230.c |   32 ++++++++++++++-----------
 net/ieee802154/6lowpan.c       |   49 +++++++++++++++++++--------------------
 net/mac802154/mac802154.h      |    1 +
 net/mac802154/mac_cmd.c        |    4 ++-
 net/mac802154/mib.c            |   16 ++++++++++++-
 5 files changed, 61 insertions(+), 41 deletions(-)

--
1.7.2.3
