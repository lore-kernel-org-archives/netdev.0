From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 0/6] prandom fixes/improvements
Date: Mon, 11 Nov 2013 12:20:31 +0100
Message-ID: <cover.1384160397.git.dborkman@redhat.com>
Cc: shemminger@networkplumber.org, fweimer@redhat.com,
	netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41614 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753024Ab3KKLUp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Nov 2013 06:20:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

It would be great if you could still consider this series that fixes and
improves prandom for 3.13. We have sent it to netdev as prandom() originally
came from net/core/utils.c and networking is its main user. For a detailled
description, please see individual patches.

For patch 3 in this series, there will be a minor merge conflict with the
random tree that is for 3.13. See below how to resolve it.

====
Hannes says: on merge with the random tree I would suggest to resolve the
conflict in drivers/char/random.c like this:

if (r->entropy_total > 128) {
	r->initialized = 1;
	r->entropy_total = 0;
	if (r == &nonblocking_pool) {
		prandom_reseed_late();
		pr_notice("random: %s pool is initialized\n",
			  r->name);
	}
}

So it won't generate a warning if DEBUG_RANDOM_BOOT gets activated.
====

Patch 1 should probably also go to -stable.

Set tested on 32 and 64 bit machines.

Thanks a lot!

Ref. original discussion: http://patchwork.ozlabs.org/patch/289951/

Daniel Borkmann (4):
  random32: fix off-by-one in seeding requirement
  random32: move rnd_state to linux/random.h
  random32: upgrade taus88 generator to taus113 from errata paper
  random32: add test cases for taus113 implementation

Hannes Frederic Sowa (2):
  random32: add periodic reseeding
  random32: add prandom_reseed_late() and call when nonblocking pool
    becomes initialized

 drivers/char/random.c       |   5 +-
 include/linux/random.h      |  14 +-
 include/uapi/linux/random.h |   7 -
 lib/Kconfig                 |   7 +
 lib/random32.c              | 307 +++++++++++++++++++++++++++++++++++++++-----
 5 files changed, 294 insertions(+), 46 deletions(-)

-- 
1.8.3.1
