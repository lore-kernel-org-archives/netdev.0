From: Antonio Quartulli <ordex@autistici.org>
Subject: pull request: batman-adv 2013-01-14
Date: Mon, 14 Jan 2013 09:41:05 +1000
Message-ID: <1358120480-25960-1-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from diserzione.investici.org ([82.221.99.153]:49306 "EHLO
	diserzione.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755309Ab3AMXmW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jan 2013 18:42:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

this is our first changeset intended for net-next/linux-3.9.
In this batch you have mostly code refactoring, style adjustments and o=
utput
beautifications.
The only new 'behaviours' are:
- prevent the TT component from learning multicast mac addresses as the=
y are not
  really handled (yet)
- initialise own lockdep class for each hash table in order to avoid fa=
lse
  positive from lockdep


Please pull or let me know if there is any problem.
Thanks a lot,
	Antonio


The following changes since commit 00494be4546432a11d62ebfeca363256ff98=
22b5:

  networking/cs89x0.txt: delete stale information about hand patching (=
2013-01-11 16:52:26 -0800)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batman-adv-for-davem

for you to fetch changes up to 0c430d0d7b8bafa74959a84156ef0bda1417a3d4=
:

  batman-adv: unbloat batadv_priv if debug is not enabled (2013-01-12 2=
0:58:23 +1000)

----------------------------------------------------------------
Included changes:
- use per_cpu_add when possible
- prevent the TT component to add multicast address as "mesh clients"
- some debug output improvements
- proper lockdeps class initializations
- new style fixes (space before/after brackets)
- other minor fixes and refactoring

----------------------------------------------------------------
Antonio Quartulli (11):
      batman-adv: reduce local TT entry timeout to 10 minutes
      batman-adv: improve local translation table output
      batman-adv: print the CRC together with the translation tables
      batman-adv: unify and properly print hex values
      batman-adv: remove useless assignment in tt_local_add()
      batman-adv: Initialize lockdep class keys for hashes
      batman-adv: remove useless blank lines before and after brackets
      batman-adv: remove useless NULL check
      batman-adv: don't compile the BLA switch if not requested
      batman-adv: use the const qualifier in hash functions
      batman-adv: fix typo in debug message

Linus L=C3=BCssing (1):
      batman-adv: Do not add multicast MAC addresses to translation tab=
le

Marek Lindner (2):
      batman-adv: remove unused variable from orig_node struct
      batman-adv: unbloat batadv_priv if debug is not enabled

Shan Wei (1):
      batman-adv: use per_cpu_add helper

 net/batman-adv/bat_iv_ogm.c            |  8 +---
 net/batman-adv/bridge_loop_avoidance.c | 24 +++++------
 net/batman-adv/debugfs.c               |  8 +---
 net/batman-adv/hash.h                  |  2 +-
 net/batman-adv/main.h                  |  6 +--
 net/batman-adv/originator.c            |  9 +++--
 net/batman-adv/routing.c               |  4 --
 net/batman-adv/send.c                  |  2 -
 net/batman-adv/soft-interface.c        |  7 +++-
 net/batman-adv/translation-table.c     | 73 ++++++++++++++++++++++----=
--------
 net/batman-adv/types.h                 |  7 +++-
 net/batman-adv/unicast.c               |  2 -
 net/batman-adv/vis.c                   |  6 +++
 13 files changed, 88 insertions(+), 70 deletions(-)
