From: Ahmed Amamou <ahmed@gandi.net>
Subject: [RFC PATCH 00/24] TRILL implementation
Date: Wed, 24 Sep 2014 17:51:56 +0200
Message-ID: <1411573940-14079-1-git-send-email-ahmed@gandi.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: william@gandi.net, f.cachereul@alphalink.fr,
	Ahmed Amamou <ahmed@gandi.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.gandi.net ([217.70.183.210]:53510 "EHLO mail4.gandi.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752976AbaIXP6J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Sep 2014 11:58:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

We have been working on a TRILL implementation in the Linux kernel for =
some
months now.  The code has been pushed here https://github.com/Gandi/ktr=
ill.git
along the way.  Attached a series of patch as a first proposition.  The=
 code is
not perfect and probably still lacks of improvements. It's a first requ=
est of
comment in order to get some feedbacks. This code has been tested for s=
ome
months now.

These patch tries to implement TRILL protocol RFC 6325.  As a First
implementation, some RFC details are still not implemented.

We still need to fix these points:=20
- The use of rtnetlink instead of the actual netlink.
- BPDU handling

Also some parts may not be fully linux compliant, so we are waiting for
comments

In order to test theses patches please follow this small wiki download =
quagga
(userland) from here https://github.com/Gandi/quagga.git compile it usi=
ng these
options ./bootstrap.sh && ./configure --localstatedir=3D/var/run/quagga
--enable-isisd --enable-trilld --disable-ipv6 --disable-ospfd
--disable-ospfclient --disable-ripd --disable-babeld --disable-bgpd && =
make &&
make install

start zebra and trilld  $ zebra -f $ZEBRA_CONF -P 2121 -u quagga -d $ t=
rilld -f
$TRILLD_CONF -P 2021 -u quagga -d

configuration sample can be found here
https://github.com/Gandi/quagga/blob/dev_trill/zebra/zebra.conf.sample =
and here
https://github.com/Gandi/quagga/blob/dev_trill/isisd/trilld.conf.sample


=46inally you need to correctly configure bridge port=20

=46or access port (native frames) echo 4 >
/sys/class/net/<INTERFACE>/brport/trill_state For trunk port (trill fra=
me and
control frames) echo 8 > /sys/class/net/<INTERFACE>/brport/trill_state=20

more detail can be found here: https://github.com/Gandi/ktrill/wiki NB:=
 for port
state github version has different flags as we did not take into consid=
eration
all port flag when implementing it

Ahmed Amamou (23):
  net: rbridge: add trill frame description
  net: rbridge: Add RBridge structure
  net: rbridge: Add CONFIG_TRILL
  net: rbridge: Adapt Bridge structure
  net: rbridge: Enable/disable TRILL capability
  net: rbridge: Add sysfs for trill_state
  net: rbridge: Add Rbridge netlink message skeleton
  net: rbridge: Get Rbridge nickname from daemon
  net: rbridge: Add elected dtroot
  net: rbridge: Add rbr_node management function
  net: rbridge: Clean up rbr_node on rbridge stop
  net: rbridge: Add set_node function
  net: rbridge: Add get_node function
  net: rbridge: Add basic trill frame handling function
  net: rbridge: Update forwarding database
  net: rbridge: Add test on trill flag before flood
  net: rbridge: Add encapsulation process
  net: rbridge: Add receive function
  net: rbridge: Add multicast recv handling
  net: rbridge: Add decapsulation function
  net: rbridge: Add rbr_fwd
  net: rbridge: Add rbr_multidest_fwd
  net: rbridge: replace net_port rx_handler

=46ran=C3=A7ois Cachereul (1):
  net: rbridge: Add layer 2 IS-IS Ethertype

 include/linux/etherdevice.h      |  34 ++
 include/linux/if_trill.h         |  89 +++++
 include/uapi/linux/if_ether.h    |   2 +
 net/bridge/Kconfig               |   8 +
 net/bridge/Makefile              |   2 +
 net/bridge/br.c                  |   6 +
 net/bridge/br_fdb.c              |  40 +++
 net/bridge/br_forward.c          |  38 ++
 net/bridge/br_if.c               |   4 +
 net/bridge/br_private.h          |  51 +++
 net/bridge/br_sysfs_br.c         |  38 ++
 net/bridge/br_sysfs_if.c         |  23 ++
 net/bridge/rbridge/rbr.c         | 723 +++++++++++++++++++++++++++++++=
++++++++
 net/bridge/rbridge/rbr_netlink.c | 404 ++++++++++++++++++++++
 net/bridge/rbridge/rbr_netlink.h |  62 ++++
 net/bridge/rbridge/rbr_private.h |  86 +++++
 16 files changed, 1610 insertions(+)
 create mode 100644 include/linux/if_trill.h
 create mode 100644 net/bridge/rbridge/rbr.c
 create mode 100644 net/bridge/rbridge/rbr_netlink.c
 create mode 100644 net/bridge/rbridge/rbr_netlink.h
 create mode 100644 net/bridge/rbridge/rbr_private.h

--=20
Ahmed Amamou=20
