From: Antonio Quartulli <a@unstable.cc>
Subject: pull request [net]: batman-adv-0160426
Date: Tue, 26 Apr 2016 11:27:14 +0800
Message-ID: <1461641239-7097-1-git-send-email-a@unstable.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:42236 "EHLO s2.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751060AbcDZD1y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Apr 2016 23:27:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

this is a batch intended for net. Changes are quite small, therefore I
hope it is not a big deal to include them at this point of the release =
cycle.

In this patchset you can find the following fixes:

1) check skb size to avoid reading beyond its border when delivering
   payloads, by Sven Eckelmann
2) initialize last_seen time in neigh_node object to prevent cleanup
   routine from accidentally purge it, by Marek Lindner
3) release "recently added" slave interfaces upon virtual/batman
   interface shutdown, by Sven Eckelmann
4) properly decrease router object reference counter upon routing table
   update, by Sven Eckelmann
5) release queue slots when purging OGM packets of deactivating slave
   interface, by Linus L=C3=BCssing

Patch 2 and 3 have no "Fixes:" tag because the offending commits date
back to when batman-adv was not yet officially in the net tree.

Note that all these changes are fixing very old commits and therefore
it would be nice if you could queue them for *stable*.

Please pull or let me know of any issue!

Thanks a lot,
	Antonio




The following changes since commit 5f44abd041c5f3be76d57579ab254d78e601=
315b:

  Merge tag 'rtc-4.6-3' of git://git.kernel.org/pub/scm/linux/kernel/gi=
t/abelloni/linux (2016-04-21 15:41:13 -0700)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batman-adv-fix-for-davem

for you to fetch changes up to c4fdb6cff2aa0ae740c5f19b6f745cbbe786d42f=
:

  batman-adv: Fix broadcast/ogm queue limit on a removed interface (201=
6-04-24 15:41:56 +0800)

----------------------------------------------------------------
In this patchset you can find the following fixes:

1) check skb size to avoid reading beyond its border when delivering
   payloads, by Sven Eckelmann
2) initialize last_seen time in neigh_node object to prevent cleanup
   routine from accidentally purge it, by Marek Lindner
3) release "recently added" slave interfaces upon virtual/batman
   interface shutdown, by Sven Eckelmann
4) properly decrease router object reference counter upon routing table
   update, by Sven Eckelmann
5) release queue slots when purging OGM packets of deactivating slave
   interface, by Linus L=C3=BCssing

Patch 2 and 3 have no "Fixes:" tag because the offending commits date
back to when batman-adv was not yet officially in the net tree.

----------------------------------------------------------------
Linus L=C3=BCssing (1):
      batman-adv: Fix broadcast/ogm queue limit on a removed interface

Marek Lindner (1):
      batman-adv: init neigh node last seen field

Sven Eckelmann (3):
      batman-adv: Check skb size before using encapsulated ETH+VLAN hea=
der
      batman-adv: Deactivate TO_BE_ACTIVATED hardif on shutdown
      batman-adv: Reduce refcnt of removed router when updating route

 net/batman-adv/hard-interface.c | 3 +--
 net/batman-adv/originator.c     | 1 +
 net/batman-adv/routing.c        | 9 +++++++++
 net/batman-adv/send.c           | 6 ++++++
 net/batman-adv/soft-interface.c | 8 ++++++--
 5 files changed, 23 insertions(+), 4 deletions(-)
