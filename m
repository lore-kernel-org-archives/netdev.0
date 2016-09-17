From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 00/14] rxrpc: Fixes & miscellany
Date: Sun, 18 Sep 2016 00:17:44 +0100
Message-ID: <147415426459.17897.13899206413543061473.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Here are some more AF_RXRPC fix patches with a couple of miscellaneous
changes also.  Fixes include:

 (1) Make RxRPC IPv6 support conditional on IPv6 being available.

 (2) Move the condition check in rxrpc_locate_data() into the caller and
     check the error return.

 (3) Fix the detection of the last received packet in recvmsg.

 (4) Account calls that need acceptance and clean up any unaccepted ones if
     the socket gets closed.

 (5) Fix the cleanup of client connections.

 (6) Fix the soft-ACK parsing and the retransmission of packets based on
     those ACKs.

 (7) Suppress transmission of an ACK when there's no pending ACK to
     transmit because another thread stole it.

And some miscellany:

 (8) Whitespace removal.

 (9) Switch-value consistency in rxrpc_send_call_packet().

(10) Fix the basic transmission packet size to allow for spur-of-the-moment
     jumbo DATA packet production.


The patches can be found here also (non-terminally on the branch):

	http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/log/?h=rxrpc-rewrite

Tagged thusly:

	git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git
	rxrpc-rewrite-20160917-1

David
---
David Howells (14):
      rxrpc: Remove some whitespace.
      rxrpc: Move the check of rx_pkt_offset from rxrpc_locate_data() to caller
      rxrpc: Check the return value of rxrpc_locate_data()
      rxrpc: Fix handling of the last packet in rxrpc_recvmsg_data()
      rxrpc: Record calls that need to be accepted
      rxrpc: Purge the to_be_accepted queue on socket release
      rxrpc: Fix the putting of client connections
      rxrpc: Call rxrpc_release_call() on error in rxrpc_new_client_call()
      rxrpc: Fix unexposed client conn release
      rxrpc: Fix the parsing of soft-ACKs
      rxrpc: Fix retransmission algorithm
      rxrpc: Don't transmit an ACK if there's no reason set
      rxrpc: Be consistent about switch value in rxrpc_send_call_packet()
      rxrpc: Fix the basic transmit DATA packet content size at 1412 bytes


 net/rxrpc/call_accept.c |    2 ++
 net/rxrpc/call_event.c  |   14 ++++--------
 net/rxrpc/call_object.c |   46 ++++++++++++++++++++---------------------
 net/rxrpc/conn_client.c |   29 ++++++++++++--------------
 net/rxrpc/input.c       |    6 ++++-
 net/rxrpc/output.c      |    7 +++++-
 net/rxrpc/recvmsg.c     |   53 ++++++++++++++++++++++++++++++++---------------
 net/rxrpc/sendmsg.c     |    2 +-
 8 files changed, 89 insertions(+), 70 deletions(-)
