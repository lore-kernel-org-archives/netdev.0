From: Antonio Quartulli <ordex@autistici.org>
Subject: pull request net: batman-adv 2013-04-22
Date: Mon, 22 Apr 2013 10:38:13 +0200
Message-ID: <1366619894-16857-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:56390 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754946Ab3DVIj6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Apr 2013 04:39:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

here we have another (I think the last) fix intended for net/linux-3.9.

This patch fixes a bug in the Translation Table component. In particular, when
batman-adv accesses the "inner Ethernet header", it has have to jump over its
header which can have two different lengths. The current code assumes
that this length is always the same and so leading to a wrong access.
This patch fixes it by making the "jump" generic.

The bug is not very critical because it "only" breaks our "smart rerouting
feature" and does not lead to a crash since the memory it accesses is always
allocated. I would send it to stable, but you can decide whether it is worth or
not.


Please pull or let me know if there is any problem.
Thanks a lot,
	Antonio

The following changes since commit 60d509fa6a9c4653a86ad830e4c4b30360b23f0e:

  Linux 3.9-rc8 (2013-04-21 14:38:45 -0700)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batman-adv-fix-for-davem

for you to fetch changes up to dd981ab091cde09bb9eb23c8d81305ba615ee30c:

  batman-adv: use the proper header len when checking the TTVN (2013-04-22 09:55:23 +0200)

----------------------------------------------------------------
Included changes:
- fix Ethernet header access by jumping the correct batman-adv header

----------------------------------------------------------------
Antonio Quartulli (1):
      batman-adv: use the proper header len when checking the TTVN

 net/batman-adv/routing.c | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)
