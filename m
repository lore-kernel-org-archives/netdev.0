From: Antonio Quartulli <ordex@autistici.org>
Subject: pull request: batman-adv 2013-03-28
Date: Thu, 28 Mar 2013 08:50:20 +0100
Message-ID: <1364457031-3194-1-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from diserzione.investici.org ([82.221.99.153]:33236 "EHLO
	diserzione.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755957Ab3C1HwI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 03:52:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

here you have another batch of patches intended for net-next/linux-3.10=
=2E

The first one fixes an endianess bug in the new network coding componen=
t,
sent within our last pull request. It was discovered thanks to
=46engguang Wu's automated daily checks on our tree (we upgraded our da=
ily
check to look for endianess bugs as well ;-))

Then you have patches from 2/11 to 8/11 implementing the RTNL API for v=
irtual
interfaces manipulation: now users can use the "ip" tool to create/dele=
te
batman-adv interfaces and to enslave real ones below them. However, to =
avoid
breaking any user tool, we did not disrupt our sysfs API.

Patch 11/11 is addressing a new checkpatch complaining by substituting =
seq_printf
with seq_puts when possible (however, checkpatch seems to be broken bec=
ause it
raises false positives in case of multi-line seq_printf).

The rest is ordinary house keeping.


Please pull or let me know if there is any problem!

Thank you,
	Antonio



The following changes since commit 6bdeaba47d87f48a3943b6899d6c6e6f17d5=
2f1d:

  6lowpan: use IEEE802154_ADDR_LEN instead of a magic number (2013-03-2=
7 00:52:16 -0400)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batman-adv-for-davem

for you to fetch changes up to 0c81465357ffe29da9ff20103afe4a59908e0d30=
:

  batman-adv: use seq_puts instead of seq_printf when the format is con=
stant (2013-03-27 10:29:55 +0100)

----------------------------------------------------------------
Included changes:
- A fix for the network coding component which has been added within th=
e last
  pull request (so it is in linux-3.10). The problem has been spotted t=
hanks to
  Fengguang Wu's automated daily checks on our tree.
- Implementation of the RTNL API for virtual interface creation/deletio=
n and slave
  manipulation
- substitution of seq_printf with seq_puts when possible
- minor cleanups

----------------------------------------------------------------
Antonio Quartulli (3):
      batman-adv: free an hard-interface before adding it
      batman-adv: update Makefile copyright years
      batman-adv: use seq_puts instead of seq_printf when the format is=
 constant

Marek Lindner (1):
      batman-adv: rename batadv_softif_destroy to reflect sysfs use cas=
e

Martin Hundeb=C3=B8ll (1):
      batman-adv: Fix endianness errors for network coding

Simon Wunderlich (1):
      batman-adv: Start new development cycle

Sven Eckelmann (5):
      batman-adv: Move soft-interface initialization to ndo_init
      batman-adv: Move deinitialization of soft-interface to destructor
      batman-adv: Don't always delete softif when last slave was remove=
d
      batman-adv: Allow to use rntl_link for device creation/deletion
      batman-adv: Allow to modify slaves of soft-interfaces through rnt=
l_link

 net/batman-adv/Makefile         |   2 +-
 net/batman-adv/gateway_client.c |   2 +-
 net/batman-adv/hard-interface.c |  66 ++++++++--
 net/batman-adv/hard-interface.h |  13 +-
 net/batman-adv/main.c           |   4 +-
 net/batman-adv/main.h           |   3 +-
 net/batman-adv/network-coding.c |  10 +-
 net/batman-adv/originator.c     |   4 +-
 net/batman-adv/packet.h         |   2 +-
 net/batman-adv/soft-interface.c | 269 ++++++++++++++++++++++++++------=
--------
 net/batman-adv/soft-interface.h |   3 +-
 net/batman-adv/sysfs.c          |   6 +-
 net/batman-adv/vis.c            |   4 +-
 13 files changed, 268 insertions(+), 120 deletions(-)
