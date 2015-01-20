From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 0/3 net-next] rhashtable: Notify on resize to allow signaling interrupted dumps
Date: Tue, 20 Jan 2015 14:20:24 +0100
Message-ID: <cover.1421759056.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: davem@davemloft.net, kaber@trash.net, herbert@gondor.apana.org.au,
	paulmck@linux.vnet.ibm.com, ying.xue@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:49361 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755113AbbATNUl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 08:20:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Netlink dumps have a traditional weakness of being interruptible and
non-atomic. Once the message buffer has been filled, all protective
locks must be released and the buffer is handed over to the user to
copy the data. The dumping then continues from the previously stored
offsets in the data structures. Due to dropping of the locks, mutations
can occur.

This first series introduces a new notification mechanism which allows
users of rhashtable to bump a sequence number on resizes and report
an inconsistent dump to user space.

As discussed in the netdev thread ("[PATCH 7/9] rhashtable: Per bucket
locks & deferred expansion/shrinking").

Thomas Graf (3):
  rhashtable: Provide notifier for deferred resizes
  netlink: Mark dumps as inconsistent which have been interrupted by a
    resize
  netlink: Lock out table resizes while dumping Netlink sockets

 include/linux/rhashtable.h | 10 +++++++++-
 lib/rhashtable.c           | 13 ++++++++++---
 net/netlink/af_netlink.c   | 10 ++++++++++
 net/netlink/af_netlink.h   |  1 +
 net/netlink/diag.c         |  4 ++++
 5 files changed, 34 insertions(+), 4 deletions(-)

-- 
1.9.3
