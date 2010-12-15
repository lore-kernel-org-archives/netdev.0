From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH 0/3] Fix NETIF_F_HW_CSUM implementations [v2]
Date: Wed, 15 Dec 2010 02:24:08 +0100 (CET)
Message-ID: <cover.1292372504.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:59361 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757659Ab0LOBYL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Dec 2010 20:24:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a split version of a patch fixing NETIF_F_HW_CSUM implementatio=
ns
in network drivers. For easier review, this is split into three patches=
:

 1. introduce skb_checksum_start_offset() helper
 2. convert correct implementations to use the helper from #1
 3. fix bad uses of skb_transport_offset() using helper from #1

Patches are against net-next, commit 0dbaee3b37e118a96bb7b8eb0d9bbaeeb4=
6264be

	net: Abstract default ADVMSS behind an accessor.

Best Regards,
Micha=C5=82 Miros=C5=82aw

---

Micha=C5=82 Miros=C5=82aw (3):
  net: Introduce skb_checksum_start_offset()
  net: Use skb_checksum_start_offset()
  net: Fix drivers advertising HW_CSUM feature to use csum_start

 drivers/net/atl1c/atl1c_main.c    |    2 +-
 drivers/net/atl1e/atl1e_main.c    |    2 +-
 drivers/net/atlx/atl1.c           |    2 +-
 drivers/net/cassini.c             |    2 +-
 drivers/net/e1000/e1000_main.c    |    2 +-
 drivers/net/e1000e/netdev.c       |    2 +-
 drivers/net/enic/enic_main.c      |    2 +-
 drivers/net/ixgb/ixgb_main.c      |    2 +-
 drivers/net/ll_temac_main.c       |    2 +-
 drivers/net/macvtap.c             |    3 +--
 drivers/net/myri10ge/myri10ge.c   |    2 +-
 drivers/net/niu.c                 |    2 +-
 drivers/net/skge.c                |    2 +-
 drivers/net/sungem.c              |    2 +-
 drivers/net/sunhme.c              |    2 +-
 drivers/net/tun.c                 |    2 +-
 drivers/net/usb/smsc95xx.c        |    7 +++----
 drivers/net/virtio_net.c          |    2 +-
 drivers/net/vmxnet3/vmxnet3_drv.c |    4 ++--
 include/linux/skbuff.h            |    5 +++++
 net/core/dev.c                    |    6 +++---
 net/core/skbuff.c                 |    2 +-
 net/ipv4/udp.c                    |    2 +-
 net/packet/af_packet.c            |    3 +--
 24 files changed, 33 insertions(+), 31 deletions(-)

--=20
1.7.2.3

