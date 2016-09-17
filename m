From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 00/11] rxrpc: Tracepoint addition and improvement
Date: Sun, 18 Sep 2016 00:21:29 +0100
Message-ID: <147415448967.18436.14900942726390485534.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Here is a set of patches that add some more tracepoints and improve a couple
of existing ones.  New additions include:

 (1) Connection refcount tracking.

 (2) Client connection state machine tracking.

 (3) Tx and Rx packet lifecycle.

 (4) ACK reception and transmission.

 (5) recvmsg processing.

Updates include:

 (1) Print the symbolic packet name in the Rx packet tracepoint.

 (2) Additional call refcount trace events.

 (3) Improvements to sk_buff tracking with AF_RXRPC.

In addition:

 (1) Config option to inject packet loss during both transmission and
     reception.

 (2) Removal of some printks.

This series needs to be applied on top of the previously posted fixes.

The patches can be found here also:

	http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/log/?h=rxrpc-rewrite

Tagged thusly:

	git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git
	rxrpc-rewrite-20160917-2

David
---
David Howells (11):
      rxrpc: Print the packet type name in the Rx packet trace
      rxrpc: Add some additional call tracing
      rxrpc: Add connection tracepoint and client conn state tracepoint
      rxrpc: Add a tracepoint to follow the life of a packet in the Tx buffer
      rxrpc: Add a tracepoint to log received ACK packets
      rxrpc: Add a tracepoint to log ACK transmission
      rxrpc: Add a tracepoint to follow packets in the Rx buffer
      rxrpc: Add a tracepoint to follow what recvmsg does
      rxrpc: Remove printks from rxrpc_recvmsg_data() to fix uninit var
      rxrpc: Improve skb tracing
      rxrpc: Add config to inject packet loss


 include/trace/events/rxrpc.h |  226 ++++++++++++++++++++++++++++++++++++++++--
 net/rxrpc/Kconfig            |    7 +
 net/rxrpc/af_rxrpc.c         |    5 +
 net/rxrpc/ar-internal.h      |  159 +++++++++++++++++++++++-------
 net/rxrpc/call_accept.c      |    7 +
 net/rxrpc/call_event.c       |    8 +
 net/rxrpc/call_object.c      |   31 ++++--
 net/rxrpc/conn_client.c      |   82 +++++++++++----
 net/rxrpc/conn_event.c       |   11 +-
 net/rxrpc/conn_object.c      |   72 +++++++++++++
 net/rxrpc/conn_service.c     |    4 +
 net/rxrpc/input.c            |   31 ++++--
 net/rxrpc/local_event.c      |    4 -
 net/rxrpc/misc.c             |   81 +++++++++++++++
 net/rxrpc/output.c           |   20 +++-
 net/rxrpc/peer_event.c       |   10 +-
 net/rxrpc/recvmsg.c          |   60 ++++++++---
 net/rxrpc/sendmsg.c          |   19 ++--
 net/rxrpc/skbuff.c           |   53 +++++++---
 19 files changed, 740 insertions(+), 150 deletions(-)
