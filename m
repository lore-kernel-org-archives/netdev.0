From: Antonio Quartulli <a@unstable.cc>
Subject: pull request [net]: batman-adv 20160216
Date: Tue, 16 Feb 2016 23:01:25 +0800
Message-ID: <1455634888-29400-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:29023 "EHLO s2.neomailbox.net"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932576AbcBPPDw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Feb 2016 10:03:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

this pull request is intended for net.

Two of the fixes included in this patchset prevent a wrong memory
access - it was triggered when removing an object from a list
after it was already free'd due to bad reference counting.
This misbehaviour existed for both the gw_node and the
orig_node_vlan object and has been fixed by Sven Eckelmann.

The last patch fixes our interface feasibility check and prevents
it from looping indefinitely when two net_device objects
reference each other via iflink index (i.e. veth pair), by
Andrew Lunn


Please pull or let me know of any problem!
Thanks a lot,
	Antonio


The following changes since commit db92ea5d4df00271b57d79c2d03dae5a5d60fcc1:

  dscc4: Undefined signed int shift (2016-02-13 06:10:21 -0500)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batman-adv-fix-for-davem

for you to fetch changes up to 1bc4e2b000e7fa9773d6623bc8850561ce10a4fb:

  batman-adv: Avoid endless loop in bat-on-bat netdevice check (2016-02-16 22:16:33 +0800)

----------------------------------------------------------------
Two of the fixes included in this patchset prevent wrong memory
access - it was triggered when removing an object from a list
after it was already free'd due to bad reference counting.
This misbehaviour existed for both the gw_node and the
orig_node_vlan object and has been fixed by Sven Eckelmann.

The last patch fixes our interface feasibility check and prevents
it from looping indefinitely when two net_device objects
reference each other via iflink index (i.e. veth pair), by
Andrew Lunn

----------------------------------------------------------------
Andrew Lunn (1):
      batman-adv: Avoid endless loop in bat-on-bat netdevice check

Sven Eckelmann (2):
      batman-adv: Only put gw_node list reference when removed
      batman-adv: Only put orig_node_vlan list reference when removed

 net/batman-adv/gateway_client.c    |  7 ++++---
 net/batman-adv/hard-interface.c    | 25 +++++++++++++++++++++++++
 net/batman-adv/translation-table.c |  6 ++++--
 3 files changed, 33 insertions(+), 5 deletions(-)
