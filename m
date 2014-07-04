From: Arvid Brodin <arvid.brodin@alten.se>
Subject: [PATCH net-next 00/10] net/hsr: Use list_head+rcu, better frame dispatch,
 etc.
Date: Fri, 4 Jul 2014 23:33:44 +0200
Message-ID: <53B71DB8.1040505@alten.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spam1.webland.se ([91.207.112.90]:61884 "EHLO spam1.webland.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760188AbaGDVkw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Jul 2014 17:40:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series is meant to improve the HSR code in several ways:

* Better code readability.
* In general, make the code structure more like the net/bridge code (HS=
R=20
  operates similarly to a bridge, but uses the HSR-specific frame heade=
rs to=20
  break up rings, instead of the STP protocol).
* Better handling of HSR ports' net_device features.
* Use list_head and the _rcu list traversing routines instead of array =
of slave=20
  devices.
* Make it easy to support HSR Interlink devices (for future Redbox/Quad=
box=20
  support).
* Somewhat better throughput on non-HAVE_EFFICIENT_UNALIGNED_ACCESS arc=
hs, due=20
  to lesser copying of skb data.

The code has been tested in a ring together with other HSR nodes runnin=
g=20
unchanged code, on both avr32 and x86_64. There should only be one mino=
r change=20
in behaviour from a user perspective:

* Anyone using the Netlink HSR_C_GET_NODE_LIST message to dump the inte=
rnal=20
  node database will notice that the database now also contains the sel=
f node.

All patches pass 'checkpatch.pl --ignore CAMELCASE --max-line-length=3D=
83=20
--strict' with only CHECKs, each of which have been deliberately left i=
n place.

The final code passes sparse checks with no output.


Arvid Brodin (10):
  net/hsr: Better variable names and update of contact info.
  net/hsr: Switch from dev_add_pack() to netdev_rx_handler_register()
  net/hsr: Move to per-hsr device prune timer.
  net/hsr: Operstate handling cleanup.
  net/hsr: Move slave init to hsr_slave.c.
  net/hsr: Use list_head (and rcu) instead of array for slave devices.
  net/hsr: Implemented .ndo_fix_features (better device features
    handling).
  net/hsr: Added SET_NETDEV_DEVTYPE and features |=3D NETIF_F_NETNS_LOC=
AL
    to dev_setup.
  net/hsr: Better frame dispatch
  net/hsr: Fix NULL pointer dereference on incomplete hsr_newlink()
    params.

 net/hsr/Makefile       |   3 +-
 net/hsr/hsr_device.c   | 580 +++++++++++++++++++++--------------------=
--------
 net/hsr/hsr_device.h   |  12 +-
 net/hsr/hsr_forward.c  | 368 +++++++++++++++++++++++++++++++
 net/hsr/hsr_forward.h  |  20 ++
 net/hsr/hsr_framereg.c | 481 ++++++++++++++++++++--------------------
 net/hsr/hsr_framereg.h |  45 ++--
 net/hsr/hsr_main.c     | 425 ++++--------------------------------
 net/hsr/hsr_main.h     |  61 ++++--
 net/hsr/hsr_netlink.c  | 102 +++++----
 net/hsr/hsr_netlink.h  |  11 +-
 net/hsr/hsr_slave.c    | 196 +++++++++++++++++
 net/hsr/hsr_slave.h    |  38 ++++
 13 files changed, 1285 insertions(+), 1057 deletions(-)
 create mode 100644 net/hsr/hsr_forward.c
 create mode 100644 net/hsr/hsr_forward.h
 create mode 100644 net/hsr/hsr_slave.c
 create mode 100644 net/hsr/hsr_slave.h

--=20
1.8.3.2

--=20
Arvid Brodin | Consultant (Linux)
ALTEN | Knarrarn=C3=A4sgatan 7 | SE-164 40 Kista | Sweden
arvid.brodin@alten.se | www.alten.se/en/
