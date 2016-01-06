From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next v2 0/3] netdev: add netdev atomic callchain to avoid driver depending on vxlan/geneve
Date: Wed,  6 Jan 2016 21:20:27 +0100
Message-ID: <1452111630-16322-1-git-send-email-hannes@stressinduktion.org>
Cc: jesse@kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:55159 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751708AbcAFUUn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 15:20:43 -0500
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id 8F99B21AD1
	for <netdev@vger.kernel.org>; Wed,  6 Jan 2016 15:20:40 -0500 (EST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This small series adds a netdev_atomic notifier chain so that drivers can
callback to the core network stack requesting to reprogram the offloads
without depending on the geneve or vxlan modules.

* Result:
$ cd drivers/net/ethernet/
$ find . -name '*.ko' | xargs modinfo | egrep  '^depends:.*(vxlan|geneve)'  | wc -l
0

Hannes Frederic Sowa (3):
  netdev: add atomic netdev callback chain
  vxlan: use netdev_atomic notifier chain to remove dependency from
    drivers
  geneve: use netdev_atomic notifier chain to remove dependency from
    drivers

 drivers/net/geneve.c      | 30 +++++++++++++++++++++++++++---
 drivers/net/vxlan.c       | 35 ++++++++++++++++++++++++++++++-----
 include/linux/netdevice.h | 10 ++++++++++
 include/net/geneve.h      |  6 ++----
 include/net/vxlan.h       |  6 ++----
 net/core/dev.c            | 24 ++++++++++++++++++++++++
 6 files changed, 95 insertions(+), 16 deletions(-)

-- 
2.5.0
