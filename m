From: Antonio Quartulli <antonio@meshcoding.com>
Subject: pull request net: batman-adv 20140510
Date: Sat, 10 May 2014 17:35:06 +0200
Message-ID: <1399736110-22333-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:11411 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750964AbaEJPga (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 May 2014 11:36:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

here you have 4 small but important patches from Simon Wunderlich intended
for net/linux-3.15 and *stable/linux-3.14* (please enqueue them).

I know it's rather late in the rc cycle but these 4 changes are addressing
some severe reference counting imbalances in different parts of code.

All these reference counting problems are rather important because they prevent
the netdev object used by batman-adv from being released and then the
system from properly shutdown/reboot/reconfigure by holding the networking stack
with the following (sad) message:

unregister_netdevice: waiting for mesh0 to become free. Usage count = 1


Please pull or let me know of any problem!

Thanks a lot,
	Antonio


The following changes since commit 1448eb566970c6d3cade522419848fdaee24c684:

  Merge branch 'for-davem' of git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless (2014-05-09 16:46:53 -0400)

are available in the git repository at:


  git://git.open-mesh.org/linux-merge.git tags/batman-adv-fix-for-davem

for you to fetch changes up to 29bcc8064fc0b82bc708c09577d550923b954e5a:

  batman-adv: fix removing neigh_ifinfo (2014-05-10 10:59:05 +0200)

----------------------------------------------------------------
Included changes:
- properly release neigh_ifinfo in batadv_iv_ogm_process_per_outif()
- properly release orig_ifinfo->router when freeing orig_ifinfo
- properly release neigh_node objects during periodic check
- properly release neigh_info objects when the related hard_iface
  is free'd

These changes are all very important because they fix some
reference counting imbalances that lead to the
impossibility of releasing the netdev object used by
batman-adv on shutdown.
The consequence is that such object cannot be destroyed by
the networking stack (the refcounter does not reach zero)
thus bringing the system in hanging state during a normal
reboot operation or a network reconfiguration.

----------------------------------------------------------------
Simon Wunderlich (4):
      batman-adv: fix neigh_ifinfo imbalance
      batman-adv: fix neigh reference imbalance
      batman-adv: always run purge_orig_neighbors
      batman-adv: fix removing neigh_ifinfo

 net/batman-adv/bat_iv_ogm.c |  2 ++
 net/batman-adv/originator.c | 59 ++++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 57 insertions(+), 4 deletions(-)
