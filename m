From: Patrick McHardy <kaber@trash.net>
Subject: [NET 00/02]: MACVLAN driver
Date: Tue, 19 Jun 2007 15:08:41 +0200 (MEST)
Message-ID: <20070619130825.26769.23059.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:57972 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755634AbXFSNIn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2007 09:08:43 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These patches add a rewritten version of Ben's macvlan driver, which
allows to create virtual ethernet devices. The underlying device is
put in promiscous mode and packets are demuxed based on MAC address.
It behaves similar to bridge devices in that packets are visible on
the real device before delivery to the macvlan driver. The driver
supports all features of the underlying device except VLAN
acceleration, this is currently very hard to support. I might look
into this in the future.

The main downside of this driver is that it adds another hook in
netif_receive_skb, unfortunately that is unavoidable. When not
compiled in the hook vanishes of course.

Usage is simple:

# ip link add link eth0 type macvlan

Will create a macvlan0 device with a random MAC address on top of
eth0. No iproute patches are required.


Please apply, thanks.


 MAINTAINERS                |    6 +
 drivers/net/Kconfig        |   10 +
 drivers/net/Makefile       |    1 +
 drivers/net/macvlan.c      |  468 ++++++++++++++++++++++++++++++++++++++++++++
 include/linux/if_macvlan.h |    9 +
 include/linux/netdevice.h  |    2 +
 net/core/dev.c             |   26 +++
 net/ethernet/eth.c         |    3 +
 8 files changed, 525 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/macvlan.c
 create mode 100644 include/linux/if_macvlan.h

Patrick McHardy (2):
      [ETHERNET]: Validate new address in eth_mac_addr
      [NET]: Add MACVLAN driver
