From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 0/7] rxrpc: Miscellany
Date: Thu, 06 Apr 2017 11:22:14 +0100
Message-ID: <149147413410.21583.16278066955827076779.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Here's a set of patches that make some minor changes to AF_RXRPC:

 (1) Store error codes in struct rxrpc_call::error as negative codes and
     only convert to positive in recvmsg() to avoid confusion inside the
     kernel.

 (2) Note the result of trying to abort a call (this fails if the call is
     already 'completed').

 (3) Don't abort on temporary errors whilst processing challenge and
     response packets, but rather drop the packet and wait for
     retransmission.

And also adds some more tracing:

 (4) Protocol errors.

 (5) Received abort packets.

 (6) Changes in the Rx window size due to ACK packet information.

 (7) Client call initiation (to allow the rxrpc_call struct pointer, the
     wire call ID and the user ID/afs_call pointer to be cross-referenced).

The patches can be found here also:

	http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/log/?h=rxrpc-rewrite

Tagged thusly:

	git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git
	rxrpc-rewrite-20170406

David
---
David Howells (7):
      rxrpc: Use negative error codes in rxrpc_call struct
      rxrpc: Note a successfully aborted kernel operation
      rxrpc: Handle temporary errors better in rxkad security
      rxrpc: Trace protocol errors in received packets
      rxrpc: Trace received aborts
      rxrpc: Trace changes in a call's receive window size
      rxrpc: Trace client call connection


 fs/afs/rxrpc.c               |   12 +--
 include/net/af_rxrpc.h       |    2 
 include/trace/events/rxrpc.h |  101 +++++++++++++++++++++++
 net/rxrpc/ar-internal.h      |   19 ++++
 net/rxrpc/call_accept.c      |    6 +
 net/rxrpc/call_event.c       |    2 
 net/rxrpc/call_object.c      |    4 -
 net/rxrpc/conn_client.c      |    1 
 net/rxrpc/conn_event.c       |   17 ++--
 net/rxrpc/input.c            |   17 +++-
 net/rxrpc/insecure.c         |   10 ++
 net/rxrpc/peer_event.c       |    2 
 net/rxrpc/recvmsg.c          |    8 +-
 net/rxrpc/rxkad.c            |  184 ++++++++++++++++++++++++++----------------
 net/rxrpc/sendmsg.c          |   17 +++-
 15 files changed, 294 insertions(+), 108 deletions(-)
