From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [RFC net-next 0/5] bonding: get rid of bond->lock
Date: Fri,  5 Sep 2014 20:16:46 +0200
Message-ID: <1409941011-5494-1-git-send-email-nikolay@redhat.com>
Cc: vfalico@gmail.com, j.vosburgh@gmail.com, andy@greyhouse.net,
	davem@davemloft.net, Nikolay Aleksandrov <nikolay@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39572 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751447AbaIESRD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Sep 2014 14:17:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,
This is only a raw version of the idea, I've only compile-tested this
patch-set but I think it's possible to remove bond->lock completely as
its current users are only few and can be either removed or converted.
I'm sending it early as RFC to see if you have any suggestions, comments
or objections, and I'll do stress-testing and lockdep next week and
resubmit it with any changes/fixes that come up in the process.

If this gets accepted in some form, a re-work of curr_slave_lock will be
following as it can be dropped in a lot of places and only kept to sync the
few users that actually need it (e.g. 3ad wq handler and slave release, alb
wq handler and active change etc).
The goal of these patchsets is to simplify bond locking as it's getting
more convoluted and unnecessarily complex, in most of the cases we should
be able to rely on RTNL or rcu alone, and if the case is more complex we
should explain/document well why we need another lock.

Best regards,
 Nikolay Aleksandrov

Nikolay Aleksandrov (5):
  bonding: 3ad: use curr_slave_lock instead of bond->lock
  bonding: alb: clean bond->lock
  bonding: procfs: clean bond->lock usage and use RTNL
  bonding: options: remove bond->lock usage
  bonding: remove last users of bond->lock and bond->lock itself

 drivers/net/bonding/bond_3ad.c     |  9 +++----
 drivers/net/bonding/bond_alb.c     | 11 ++------
 drivers/net/bonding/bond_main.c    | 51 ++++++--------------------------------
 drivers/net/bonding/bond_options.c | 19 +-------------
 drivers/net/bonding/bond_procfs.c  |  8 ++----
 drivers/net/bonding/bonding.h      |  8 ++----
 6 files changed, 18 insertions(+), 88 deletions(-)

-- 
1.9.3
