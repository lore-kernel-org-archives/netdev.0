From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 0/4] rxrpc: Support IPv6 [ver #2]
Date: Thu, 15 Sep 2016 00:06:00 +0100
Message-ID: <147389436004.2083.13454744739435764689.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


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

Changes:

 (V2) Made IPv6 support conditional on CONFIG_IPV6.

      Changed a memcpy argument that was taking the address of an array
      struct member (with the '&' operator) and adding 12 to just add 12 to
      the array member.  This otherwise causes a problem on gcc-4.9.

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


 net/rxrpc/Kconfig        |    7 +++
 net/rxrpc/af_rxrpc.c     |   32 +++++++++++-
 net/rxrpc/conn_object.c  |   10 ++++
 net/rxrpc/local_event.c  |   13 ++---
 net/rxrpc/local_object.c |   41 +++++++---------
 net/rxrpc/output.c       |   50 +++++++++----------
 net/rxrpc/peer_event.c   |   26 ++++++++++
 net/rxrpc/peer_object.c  |  119 ++++++++++++++++++++++++++++++----------------
 net/rxrpc/proc.c         |   30 +++++-------
 net/rxrpc/utils.c        |    2 +
 10 files changed, 211 insertions(+), 119 deletions(-)
