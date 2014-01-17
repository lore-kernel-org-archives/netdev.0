From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next v2 0/3] reciprocal_divide updates
Date: Fri, 17 Jan 2014 01:28:36 +0100
Message-ID: <1389918519-23779-1-git-send-email-hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:44123 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751298AbaAQA2p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 19:28:45 -0500
Received: from stressinduktion.org (localhost.localdomain [127.0.0.1])
	by order.stressinduktion.org (Postfix) with ESMTP id 75C0C1A0C287
	for <netdev@vger.kernel.org>; Fri, 17 Jan 2014 01:28:43 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set is on top of Eric's BPF fix, that is:
  
  <http://patchwork.ozlabs.org/patch/311163/>

This fix is currently in the net repository; a merge of net to net-next
would be needed for this series. 

Included Patches:

Daniel Borkmann (2):
      random32: add prandom_u32_max and convert open coded users
      net: add trim helper and convert users

Hannes Frederic Sowa (1):
      reciprocal_divide: correction/update of the algorithm

Diffstat:
 drivers/net/bonding/bond_main.c     | 24 +++++++++++++++++-------
 drivers/net/bonding/bond_netlink.c  |  4 ----
 drivers/net/bonding/bond_options.c  | 15 ++++++++++----- 
 drivers/net/bonding/bond_sysfs.c    |  5 -----
 drivers/net/bonding/bonding.h       |  3 +++
 drivers/net/team/team_mode_random.c |  8 +-------
 include/linux/flex_array.h          |  3 ++-
 include/linux/kernel.h              | 19 +++++++++++++++++++
 include/linux/random.h              | 19 ++++++++++++++++++-
 include/linux/reciprocal_div.h      | 39 +++++++++++++++++++++------------------
 include/linux/slab_def.h            |  4 +++-
 include/net/codel.h                 |  4 +---
 include/net/red.h                   |  3 ++-
 lib/flex_array.c                    |  7 ++++++-
 lib/reciprocal_div.c                | 24 ++++++++++++++++++++----
 net/packet/af_packet.c              |  5 ++---
 net/sched/sch_choke.c               |  9 +--------
 net/sched/sch_netem.c               |  6 ++++--
 18 files changed, 130 insertions(+), 71 deletions(-)

Changelog:
v2)
* change function name to prandom_u32_max as suggested by Joe Perches
* first patch split into two patches, second one introduces helper
  function trim (suggested by Eric Dumazet to not go back to open-coded
  version and David Laight to rename reciprocal_divide())
* removed RECIPROCAL_VALUE_RESULT_TO_ZERO as it causes undefined behaviour
  and is broken (thanks Ben Hutchings!)
* reworded
