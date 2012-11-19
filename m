From: Antonio Quartulli <ordex@autistici.org>
Subject: pull request: batman-adv 2012-11-19
Date: Mon, 19 Nov 2012 09:24:01 +0100
Message-ID: <1353313451-2930-1-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:64042 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752829Ab2KSIZP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 03:25:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

this should be our last batch of patches intended for net-next/linux-3.=
8.
In this patchset we have patches 7,8/10 by Sven Eckelmann which improve=
 the crc
computation on broadcast packets (in the Bridge Loop Avoidance componen=
t) by
using crc32c and by avoiding the entire linearisation of the skb! Then,=
 patch
4/10 introduces a new debugfs file which exports the compatibility vers=
ion so
that users having different batman-adv releases can understand whether =
they can
or cannot communicate.
Patch 10/10 removes the packed attribute for the unicast message type a=
nd adds
"#pragma pack(2)" (again, this is just part of our intermediate changes=
 which do
not break compatibility. The real restructure will come later..).


The others are cleanups or small code refactoring.


Let me know if there is any problem!

Thank you,
	Antonio


The following changes since commit 3594698a1fb8e5ae60a92c72ce9ca2802569=
39a7:

  net: Make CAP_NET_BIND_SERVICE per user namespace (2012-11-18 20:33:3=
7 -0500)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batman-adv-for-davem

for you to fetch changes up to 15401e33ef94d4f251c42e8228e6c387327f38f8=
:

  batman-adv: Use packing of 2 for all headers before an ethernet heade=
r (2012-11-19 09:14:11 +0100)

----------------------------------------------------------------
Included changes:
- Increase batman-adv version
- Bridge Loop Avoidance: compute checksum (using crc32) on skb fragment=
s instead
  of linearising it
- sort the sysfs documentation
- export the compatibility version via debugfs
- some other minor cleanups

----------------------------------------------------------------
Antonio Quartulli (2):
      batman-adv: support array of debugfs general attributes
      batman-adv: export compatibility version via debugfs

Marek Lindner (1):
      batman-adv: sysfs documentation should keep alphabetical order

Martin Hundeb=C3=B8ll (1):
      batman-adv: Add wrapper to look up neighbor and send skb

Simon Wunderlich (2):
      batman-adv: fix bla compare function
      batman-adv: Fix broadcast duplist for fragmentation

Sven Eckelmann (4):
      batman-adv: Mark best gateway in transtable_global debugfs
      batman-adv: Add function to calculate crc32c for the skb payload
      batman-adv: Start new development cycle
      batman-adv: Use packing of 2 for all headers before an ethernet h=
eader

 .../ABI/testing/sysfs-class-net-batman-adv         |  11 +-
 Documentation/ABI/testing/sysfs-class-net-mesh     |  40 +++---
 net/batman-adv/Kconfig                             |   1 +
 net/batman-adv/bridge_loop_avoidance.c             |  36 +++--
 net/batman-adv/bridge_loop_avoidance.h             |   6 +-
 net/batman-adv/debugfs.c                           |  46 ++++--
 net/batman-adv/main.c                              |  46 ++++++
 net/batman-adv/main.h                              |   4 +-
 net/batman-adv/packet.h                            |  16 ++-
 net/batman-adv/routing.c                           |  45 ++----
 net/batman-adv/send.c                              |  33 +++++
 net/batman-adv/send.h                              |   3 +
 net/batman-adv/translation-table.c                 | 155 +++++++++++--=
--------
 net/batman-adv/types.h                             |   2 +-
 net/batman-adv/unicast.c                           |   8 +-
 net/batman-adv/vis.c                               |  35 ++---
 16 files changed, 293 insertions(+), 194 deletions(-)
