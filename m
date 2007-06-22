From: Patrick McHardy <kaber@trash.net>
Subject: [NET 00/05]: Secondary unicast address support v2
Date: Fri, 22 Jun 2007 14:24:05 +0200 (MEST)
Message-ID: <20070622122330.15215.47821.sendpatchset@localhost.localdomain>
Cc: Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62389 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752223AbXFVMYH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jun 2007 08:24:07 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an updated version of the secondary unicast address patches. I've
introduced a common structure and helpers for both unicast and multicast
addresses to make it easier for virtual software devices that want to
synchronize addresses to a lower device to reuse code. Additionally I
fixed a deadlock when putting the device into promiscous mode, renamed
dev->set_address_list to dev->set_rx_mode and cleaned the code up a bit.

One remaining question is how to handle the case that too many unicast
addresses are configured and the device is put into promiscous mode
or unicast filtering is disabled by the driver. In that case we're not
getting the message that is normally printed by dev_set_promiscous
and no audit log. Not sure if that can already happen when configuring
multicast, I thought it was worth mentioning.



 drivers/net/e1000/e1000_main.c |   47 ++++++---
 include/linux/netdevice.h      |   40 +++++---
 net/core/dev.c                 |  213 ++++++++++++++++++++++++++++++++++++---
 net/core/dev_mcast.c           |  128 +++---------------------
 net/decnet/dn_dev.c            |    3 -
 5 files changed, 269 insertions(+), 162 deletions(-)

Patrick McHardy (5):
      [NET]: dev_mcast: unexport dev_mc_upload
      [NET]: dev: introduce generic net_device address lists
      [NET]: dev_mcast: switch to generic net_device address lists
      [NET]: dev: secondary unicast address support
      [E1000]: Secondary unicast address support
