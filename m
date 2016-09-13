From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 0/4] rxrpc: Support IPv6
Date: Tue, 13 Sep 2016 23:41:31 +0100
Message-ID: <147380649153.30728.6717292274642860064.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60898 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1759472AbcIMWle (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 13 Sep 2016 18:41:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Here is a set of patches that add IPv6 support.  They need to be applied on
top of the just-posted miscellaneous fix patches.  They are:

 (1) Make autobinding of an unconnected socket work when sendmsg() is
     called to initiate a client call.

 (2) Don't specify the protocol when creating the client socket, but rather
     take the default instead.

 (3) Use rxrpc_extract_addr_from_skb() in a couple of places that were
     doing the same thing manually.  This allows the IPv6 address
     extraction to be done in fewer places.

 (4) Add IPv6 support.  With this, calls can be made to IPv6 servers from
     userspace AF_RXRPC programs; AFS, however, can't use IPv6 yet as the
     RPC calls need to be upgradeable.

The patches can be found here also:

	http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/log/?h=rxrpc-rewrite

Tagged thusly:

	git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git
	rxrpc-rewrite-20160913-2

David
---
David Howells (4):
      rxrpc: Create an address for sendmsg() to bind unbound socket with
      rxrpc: Don't specify protocol to when creating transport socket
      rxrpc: Use rxrpc_extract_addr_from_skb() rather than doing this manually
      rxrpc: Add IPv6 support


 net/rxrpc/af_rxrpc.c     |   27 ++++++++++-
 net/rxrpc/conn_object.c  |    8 +++
 net/rxrpc/local_event.c  |   13 ++---
 net/rxrpc/local_object.c |   39 +++++++---------
 net/rxrpc/output.c       |   48 +++++++++-----------
 net/rxrpc/peer_event.c   |   24 ++++++++++
 net/rxrpc/peer_object.c  |  109 +++++++++++++++++++++++++++++-----------------
 net/rxrpc/proc.c         |   30 +++++--------
 8 files changed, 179 insertions(+), 119 deletions(-)
