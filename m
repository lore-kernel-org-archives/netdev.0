From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 00/04]: Fix axrpc/afs related bugs
Date: Thu,  3 May 2007 02:04:13 +0200 (MEST)
Message-ID: <20070503000256.30775.81929.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	howells@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48171 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1767261AbXECAEO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2007 20:04:14 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These patches fix two bugs introduced by the RXRPC patches. While looking
at the other code that came in with these patches, I noticed it includes
an entire rtnetlink client in the kernel, which doesn't seem to make much
sense since all the information is available in much easier ways, so I've
replaced it by two small helper functions that should do exactly the same.

Unless I'm missing something fundamental, please apply :)


 fs/afs/Makefile           |    2 
 fs/afs/cmservice.c        |    1 
 fs/afs/internal.h         |    1 
 fs/afs/netdevices.c       |   54 +++++
 fs/afs/use-rtnetlink.c    |  473 ----------------------------------------------
 include/linux/netdevice.h |    1 
 net/core/dev.c            |   21 +-
 net/netlink/af_netlink.c  |    6 
 8 files changed, 75 insertions(+), 484 deletions(-)

Patrick McHardy (4):
      [NETLINK]: Fix use after free in netlink_recvmsg
      [AFS]: Fix memory leak in SRXAFSCB_GetCapabilities
      [NET]: Add __dev_getfirstbyhwtype
      [AFS]: Replace rtnetlink client by direct dev_base walking
