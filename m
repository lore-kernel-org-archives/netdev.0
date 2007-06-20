From: Patrick McHardy <kaber@trash.net>
Subject: [RFC NET 00/02]: Secondary unicast address support
Date: Wed, 20 Jun 2007 20:00:22 +0200 (MEST)
Message-ID: <20070620180017.6685.70611.sendpatchset@localhost.localdomain>
Cc: Patrick McHardy <kaber@trash.net>, shemminger@linux-foundation.org,
	davem@davemloft.net, jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54995 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755420AbXFTSAY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2007 14:00:24 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These two patches contain a first short at secondary unicast address support.
I'm still working on converting macvlan as an example, but since I'm about to
leave for tonight I thougth I'd get them out for some comments now.

The patch adds two new functions dev_unicast_add and dev_unicast_delete to
add/remove addresses. Similar to dev_mc_add/dev_mc_delete they do refcounting
of the addresses and the address on a list associated with the device.

dev_address_upload is responsible for uploading both the multicast and
unicast list to the device. Devices that are capable of filtering multiple
unicast addresses need to provide a function dev->set_address_list that
deals with setting both unicast and multicast address filters. This seemed
like the easiest way for chips containing filters that can be used for
any address type, also parts of the logic when to use HW filters is similar
for unicast and multicast addresses. Devices not providing this function
are put in promiscous mode when secondary addresses are present and the
old set_multicast_list function is called to take care of multicast
filtering.

The dev_uc_list structure is kept similar to dev_mc_list to allow easier
integration in existing "fill address filters" loops.

E1000 is converted as an example, the patch worked fine in some limited
testing.

Comments welcome.


 drivers/net/e1000/e1000_main.c |   39 ++++++---
 include/linux/netdevice.h      |   17 ++++
 net/core/dev.c                 |  172 ++++++++++++++++++++++++++++++++++++++--
 net/core/dev_mcast.c           |   34 +-------
 4 files changed, 212 insertions(+), 50 deletions(-)

Patrick McHardy (2):
      [NET]: Secondary unicast address support
      [E1000]: Secondary unicast address support
