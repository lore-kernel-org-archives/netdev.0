From: Antonio Quartulli <antonio@meshcoding.com>
Subject: pull request: batman-adv 2014-08-05
Date: Tue,  5 Aug 2014 09:36:24 +0200
Message-ID: <1407224188-28626-1-git-send-email-antonio@meshcoding.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:15204 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753748AbaHEHhM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2014 03:37:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

this is a pull request intended for net-next/linux-3.17 (yeah..it's rea=
lly
late).

Patches 1, 2 and 4 are really minor changes:
- kmalloc_array is substituted to kmalloc when possible (as suggested b=
y
  checkpatch);
- net_ratelimited() is now used properly and the "suppressed" message i=
s not
  printed anymore if not needed;
- the internal version number has been increased to reflect our current=
 version.

Patch 3 instead is introducing a change in the metric computation funct=
ion
by changing the penalty applied at each mesh hop from 15/255 (~6%) to
30/255 (~11%). This change is introduced by Simon Wunderlich after havi=
ng
observed a performance improvement in several networks when using the n=
ew value.


Please pull or let me know of any problem!

Thanks a lot,
	Antonio



The following changes since commit e6b92c25d20c64c271ef429bba8febeefb84=
8b5b:

  cxgb4i : remove spurious use of rcu (2014-08-02 20:34:33 -0700)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batman-adv-for-davem

for you to fetch changes up to 0028c72ec4300997f2d0b73594f391983090463b=
:

  batman-adv: Start new development cycle (2014-08-04 16:03:13 +0200)

----------------------------------------------------------------
Included changes:
- kmalloc_array instead of kmalloc when possible
- avoid log spam due to useless net_ratelimit() invocations
- increase default metric hop penalty from 15 to 30
- update internal version number

----------------------------------------------------------------
Andr=C3=A9 Gaul (1):
      batman-adv: remove unnecessary logspam

Antonio Quartulli (1):
      batman-adv: prefer kmalloc_array to kmalloc when possible

Simon Wunderlich (2):
      batman-adv: increase default hop penalty
      batman-adv: Start new development cycle

 net/batman-adv/bat_iv_ogm.c            | 13 +++++++------
 net/batman-adv/distributed-arp-table.c |  3 ++-
 net/batman-adv/hash.c                  |  6 +++---
 net/batman-adv/main.h                  | 22 +++++++++++++++-------
 net/batman-adv/routing.c               | 18 +++++++++---------
 net/batman-adv/soft-interface.c        |  2 +-
 6 files changed, 37 insertions(+), 27 deletions(-)
