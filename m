From: Antonio Quartulli <antonio@meshcoding.com>
Subject: pull request net: 20140515
Date: Thu, 15 May 2014 20:50:48 +0200
Message-ID: <1400179852-4064-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:8185 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752681AbaEOSxI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 14:53:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

our debugging campaign continues..

Here I have another small set of fixes intended for net/linux-3.15 and *stable*
(please enqueue them).

I know we already sent some fixes and we are running late in the rc cycle, but,
as you can see from the stats below, the changes are very very small.

Patch 1 prevents a NULL dereference in batadv_orig_hardif_seq_print_text() along
the failure path.

Patch 2 fixes a reference counting imbalance that gets triggered everytime the
batman packet fragmentation mechanism is used; this imbalance prevents the
netdev object held by batman-adv from being released on shutdown.

Patch 3 fixes the reference counting for the orig_node objects in order to avoid
any access after they have been free'd.

Patch 4 fixes the TT local check in DAT (Distributed ARP Table) that is used to
avoid sending (self-forged) ARP replies on behalf of other host in the LAN.





Please pull or let me know of any problem!

Thanks a lot,
	Antonio





The following changes since commit e84d2f8d2ae33c8215429824e1ecf24cbca9645e:

  net: filter: s390: fix JIT address randomization (2014-05-14 16:10:16 -0400)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batman-adv-fix-for-davem

for you to fetch changes up to cc2f33860cea0e48ebec096130bd0f7c4bf6e0bc:

  batman-adv: fix local TT check for outgoing arp requests in DAT (2014-05-15 20:23:47 +0200)

----------------------------------------------------------------
Include changes:
- fix NULL dereference in batadv_orig_hardif_seq_print_text()
- fix reference counting imbalance when using fragmentation
- avoid access to orig_node objects after they have been free'd
- fix local TT check for outgoing arp requests in DAT

----------------------------------------------------------------
Antonio Quartulli (3):
      batman-adv: fix reference counting imbalance while sending fragment
      batman-adv: increase orig refcount when storing ref in gw_node
      batman-adv: fix local TT check for outgoing arp requests in DAT

Marek Lindner (1):
      batman-adv: fix indirect hard_iface NULL dereference

 net/batman-adv/distributed-arp-table.c |  3 +--
 net/batman-adv/fragmentation.c         | 11 ++++++++---
 net/batman-adv/gateway_client.c        | 11 +++++++++--
 net/batman-adv/originator.c            |  3 ++-
 4 files changed, 20 insertions(+), 8 deletions(-)
