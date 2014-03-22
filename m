From: Antonio Quartulli <antonio@meshcoding.com>
Subject: pull request: batman-adv 20140322
Date: Sat, 22 Mar 2014 09:56:00 +0100
Message-ID: <1395478576-10999-1-git-send-email-antonio@meshcoding.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:49090 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750706AbaCVI4o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Mar 2014 04:56:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

here you have our patchset for net-next/linux-3.15.
They are 16 patches but most of them are just small cleanups and kernel=
doc
improvements.

The only big change is the one from patch 8 to 13 by Linus L=C3=BCssing=
 that
introduces a new multicast packets optimisation. This new component aim=
s to
reduce the air overhead by sending multicast packets as bat-unicast
when only one destination exists or by dropping them directly at the so=
urce if
the multicast group is totally empty.

In patch 11 Linus introduces an atomic_t variable, that like others tha=
t we
already have is only object of write and read, thus making the atomic
characteristic totally useless.
Unfortunately this is part of our sysfs framework, that helps the devel=
oper to
introduce new knobs by using few macros only. For this reason we decide=
d to keep
Linus' new knob for now, but I'd like to let you know that we are in th=
e process
of re-working such framework in order to convert all the current (usele=
ss)
atomic_t to boolean in one go.


Please pull or let me know of any problem!

Thanks a lot,
	Antonio


The following changes since commit 65025079d2ddb8091d30b356c0b0f79a8d22=
54c4:

  Merge branch 'ptp-next' (2014-03-21 14:21:45 -0400)

are available in the git repository at:


  git://git.open-mesh.org/linux-merge.git tags/batman-adv-for-davem

for you to fetch changes up to 3f2532fcde67faf496fa21c5c04c5e8cf73c9e01=
:

  batman-adv: Start new development cycle (2014-03-22 09:18:59 +0100)

----------------------------------------------------------------
Included changes:
- use ether_addr_copy instead of memcpy when possible
- implement new multicast packet optimisation
- improve several kerneldoc sections
- minor code cleanups

----------------------------------------------------------------
Antonio Quartulli (4):
      batman-adv: prefer ether_addr_copy to memcpy
      batman-adv: add kerneldoc for dst_hint argument
      batman-adv: improve the TT flags documentation
      batman-adv: improve DAT documentation

=46engguang Wu (1):
      batman-adv: fix coccinelle warnings

Linus L=C3=BCssing (8):
      batman-adv: use vlan_/eth_hdr() instead of skb->data in interface=
_tx path
      batman-adv: remove obsolete skb_reset_mac_header() in batadv_bla_=
tx()
      batman-adv: Multicast Listener Announcements via Translation Tabl=
e
      batman-adv: introduce capability initialization bitfield
      batman-adv: Announce new capability via multicast TVLV
      batman-adv: Modified forwarding behaviour for multicast packets
      batman-adv: Add IPv4 link-local/IPv6-ll-all-nodes multicast suppo=
rt
      batman-adv: Send multicast packets to nodes with a WANT_ALL flag

Marek Lindner (1):
      batman-adv: call unregister_netdev() to have it handle the lockin=
g for us

Simon Wunderlich (2):
      batman-adv: fix a few kerneldoc inconsistencies
      batman-adv: Start new development cycle

 Documentation/ABI/testing/sysfs-class-net-mesh |   9 +
 net/batman-adv/Kconfig                         |   9 +
 net/batman-adv/Makefile                        |   1 +
 net/batman-adv/bat_iv_ogm.c                    |  10 +-
 net/batman-adv/bridge_loop_avoidance.c         |  35 +-
 net/batman-adv/distributed-arp-table.c         |   9 +-
 net/batman-adv/distributed-arp-table.h         |   3 +
 net/batman-adv/fragmentation.c                 |   4 +-
 net/batman-adv/gateway_client.c                |   8 +-
 net/batman-adv/icmp_socket.c                   |  11 +-
 net/batman-adv/main.c                          |  19 +-
 net/batman-adv/main.h                          |   4 +-
 net/batman-adv/multicast.c                     | 748 +++++++++++++++++=
++++++++
 net/batman-adv/multicast.h                     |  80 +++
 net/batman-adv/network-coding.c                |  26 +-
 net/batman-adv/originator.c                    |  11 +-
 net/batman-adv/packet.h                        |  53 +-
 net/batman-adv/routing.c                       |  17 +-
 net/batman-adv/send.c                          |  31 +-
 net/batman-adv/send.h                          |   7 +
 net/batman-adv/soft-interface.c                |  48 +-
 net/batman-adv/sysfs.c                         |   6 +
 net/batman-adv/translation-table.c             | 140 +++--
 net/batman-adv/translation-table.h             |   2 +
 net/batman-adv/types.h                         |  90 ++-
 25 files changed, 1237 insertions(+), 144 deletions(-)
 create mode 100644 net/batman-adv/multicast.c
 create mode 100644 net/batman-adv/multicast.h
