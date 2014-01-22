From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next v5 0/0] reciprocal_divide update
Date: Wed, 22 Jan 2014 02:29:38 +0100
Message-ID: <1390354181-5080-1-git-send-email-hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:56758 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754073AbaAVB3o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jan 2014 20:29:44 -0500
Received: from stressinduktion.org (localhost.localdomain [127.0.0.1])
	by order.stressinduktion.org (Postfix) with ESMTP id C826D1A0C206
	for <netdev@vger.kernel.org>; Wed, 22 Jan 2014 02:29:42 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is on top of aee636c4809fa5 ("bpf: do not use reciprocal
divide") from Eric that sits in net tree. It will not create a merge
conflict, but it depends on this one, so we suggest, if possible, to
merge net into net-next.

We are proposing this change with only small modifications from the
v2 version, namely updating the name of trim to reciprocal_scale
(as commented on by Ben Hutchings and Eric Dumazet, thanks!).

We thought about introducing the reciprocal_divide algorithm in
parallel to the one already used by the kernel but faced organizational
issues, leading us to the conclusion that it is best to just replace
the old one: We could not come up with names for the different
implementations and also with a way to describe the differences to
guide developers which one to choose in which situation. This is
because we cannot specify the correct semantics for the version
which is currently used by the kernel. Altough it seems to not be
causing problems in the kernel, we cannot surely say so in the
case of flex_array for the future. Current usage seems ok, but
future users could run into problems.

Changelog:

v1->v2:
 - changed name to prandom_u32_max in p1
 - changed name to trim in p2
 - reworked code in p3
v2->v3:
 - p1 and p3 stays unchanged, only small update in commit
   message in p3
 - changed name to reciprocal_scale in p2
 - fixed kernel doc format
v3->v4:
 - pseduo -> pseudo (thanks to Tilman Schmidt)
v4->v5:
 - fix pseduo -> pseudo for real now, sorry for the noise

Thanks !

Daniel Borkmann (2):
  random32: add prandom_u32_max and convert open coded users
  net: introduce reciprocal_scale helper and convert users

Hannes Frederic Sowa (1):
  reciprocal_divide: update/correction of the algorithm

 drivers/net/bonding/bond_main.c     | 24 ++++++++++++++++-------
 drivers/net/bonding/bond_netlink.c  |  4 ----
 drivers/net/bonding/bond_options.c  | 15 +++++++++-----
 drivers/net/bonding/bond_sysfs.c    |  5 -----
 drivers/net/bonding/bonding.h       |  3 +++
 drivers/net/team/team_mode_random.c |  8 +-------
 include/linux/flex_array.h          |  3 ++-
 include/linux/kernel.h              | 19 ++++++++++++++++++
 include/linux/random.h              | 18 ++++++++++++++++-
 include/linux/reciprocal_div.h      | 39 ++++++++++++++++++++-----------------
 include/linux/slab_def.h            |  4 +++-
 include/net/codel.h                 |  4 +---
 include/net/red.h                   |  3 ++-
 lib/flex_array.c                    |  7 ++++++-
 lib/reciprocal_div.c                | 24 +++++++++++++++++++----   
 net/packet/af_packet.c              |  5 ++---
 net/sched/sch_choke.c               |  9 +--------
 net/sched/sch_netem.c               |  6 ++++--
 18 files changed, 129 insertions(+), 71 deletions(-)
