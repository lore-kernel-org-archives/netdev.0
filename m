From: Antonio Quartulli <a@unstable.cc>
Subject: pull request [net-next]: batman-adv 20160229
Date: Mon, 29 Feb 2016 19:05:53 +0800
Message-ID: <1456743968-17562-1-git-send-email-a__48581.184706609$1456744133$gmane$org@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:12489 "EHLO s2.neomailbox.net"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752014AbcB2LIi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Feb 2016 06:08:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

this is our (hopefully) latest batch of patches intended for net-next.

With this patchset we finally introduce B.A.T.M.A.N. V: the latest
version of our routing protocol.
Technical documentation describing the protocol in more detail can
be found in our wiki[1][2][3][4].


For what concerns this pull request, you can find the high level
description right below.


Please pull or let me know of any problem!
Thank you very much,
	Antonio


[1] https://www.open-mesh.org/projects/batman-adv/wiki/BATMAN_V
[2] https://www.open-mesh.org/projects/batman-adv/wiki/OGMv2
[3] https://www.open-mesh.org/projects/batman-adv/wiki/ELP
[4] https://www.open-mesh.org/projects/batman-adv/wiki/BATMAN_V_Tests



The following changes since commit f12d33f4d83c6837d176e1aef337914089c77957:

  3c59x: Ensure to apply the expires time (2016-02-28 23:39:26 -0500)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batman-adv-for-davem

for you to fetch changes up to 8b823170550e5dcc80512143088c9f9e24598f9a:

  MAINTAINERS: Add patchwork URL for BATMAN ADVANCED (2016-02-29 16:25:09 +0800)

----------------------------------------------------------------
With this patchset we finally introduce our new routing protocol:
B.A.T.M.A.N. V. Its implementation started quite some years ago,
but due to the big changes being introduced it took a while to be
discussed, designed, worked, re-worked, tested and debugged (well,
we're never done with the latest). The entire operation has
basically been a team work involving all the core contributors
together with other people interested in the project.

The new protocol is divided into two main subcomponents, called
respectively ELP and OGMv2. The former is in charge of
dealing with the neighbour discovery and link quality estimation,
while the latter implements the algorithm that spreads the
metrics around the network and computes optimal paths.

The biggest change introduced with B.A.T.M.A.N. V is the new
metric: the protocol won't rely on packet loss anymore, but it
will use the estimated throughput extracted directly from the
wifi driver (when available) by querying cfg80211.
Batman-adv will also send some unicast probing packets when
an interface is not used for payload traffic to make sure that
such values are current.

The new protocol can be compiled-in or not like other
features we have and when selected will pull in CFG80211 as
dependency for the reason described above.

Thanks to the big work brought up in the past by Marek Lindner,
batman-adv can easily deal several protocol implementations,
therefore compiling in this new version does not exclude the
older.
This means that the user is offered the option to choose
the protocol when creating the mesh interface (default is the
old one to keep backward compatibility).

Along with the protocol there are some sysfs knobs that are
introduced to fine tune some of its behaviours, but users
are recommended to keep the default values unless they know
what they are doing.

The last patch is about advertising our own patchwork platform
(thanks to Sven Eckelmann for having set that up!) in the
MAINTAINERS file.

----------------------------------------------------------------
Antonio Quartulli (8):
      batman-adv: OGMv2 - add basic infrastructure
      batman-adv: OGMv2 - implement originators logic
      batman-adv: add throughput override attribute to hard_ifaces
      batman-adv: keep track of when unicast packets are sent
      batman-adv: ELP - compute the metric based on the estimated throughput
      batman-adv: ELP - send unicast ELP packets for throughput sampling
      batman-adv: B.A.T.M.A.N. V - implement neighbor comparison API calls
      batman-adv: B.A.T.M.A.N. V - implement bat_orig_print API

Linus Luessing (5):
      batman-adv: Add hard_iface specific sysfs wrapper macros for UINT
      batman-adv: ELP - adding basic infrastructure
      batman-adv: ELP - creating neighbor structures
      batman-adv: ELP - adding sysfs parameter for elp interval
      batman-adv: B.A.T.M.A.N. V - implement bat_neigh_print API

Simon Wunderlich (1):
      batman-adv: Start new development cycle

Sven Eckelmann (1):
      MAINTAINERS: Add patchwork URL for BATMAN ADVANCED

 .../ABI/testing/sysfs-class-net-batman-adv         |  17 +-
 MAINTAINERS                                        |   1 +
 net/batman-adv/Kconfig                             |  14 +
 net/batman-adv/Makefile                            |   3 +
 net/batman-adv/bat_algo.h                          |  28 +-
 net/batman-adv/bat_iv_ogm.c                        |   2 +-
 net/batman-adv/bat_v.c                             | 347 +++++++++
 net/batman-adv/bat_v_elp.c                         | 515 +++++++++++++
 net/batman-adv/bat_v_elp.h                         |  33 +
 net/batman-adv/bat_v_ogm.c                         | 833 +++++++++++++++++++++
 net/batman-adv/bat_v_ogm.h                         |  36 +
 net/batman-adv/distributed-arp-table.c             |   4 +-
 net/batman-adv/fragmentation.c                     |   8 +-
 net/batman-adv/gateway_common.c                    |   4 +-
 net/batman-adv/gateway_common.h                    |   2 +
 net/batman-adv/icmp_socket.c                       |   2 +-
 net/batman-adv/main.c                              |   7 +
 net/batman-adv/main.h                              |  12 +-
 net/batman-adv/network-coding.c                    |  22 +-
 net/batman-adv/packet.h                            |  49 ++
 net/batman-adv/send.c                              |  55 +-
 net/batman-adv/send.h                              |  10 +-
 net/batman-adv/sysfs.c                             | 130 ++++
 net/batman-adv/types.h                             |  93 +++
 24 files changed, 2190 insertions(+), 37 deletions(-)
 create mode 100644 net/batman-adv/bat_v.c
 create mode 100644 net/batman-adv/bat_v_elp.c
 create mode 100644 net/batman-adv/bat_v_elp.h
 create mode 100644 net/batman-adv/bat_v_ogm.c
 create mode 100644 net/batman-adv/bat_v_ogm.h
