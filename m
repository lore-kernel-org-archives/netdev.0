From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 0/7] rxrpc: More fixes and adjustments
Date: Fri, 30 Sep 2016 22:40:11 +0100
Message-ID: <147527161156.28826.2148784664652062075.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This set of patches contains some more fixes and adjustments:

 (1) Actually display the retransmission indication previously added to the
     tx_data trace.

 (2) Switch to Congestion Avoidance mode properly at cwnd==ssthresh rather
     than relying on detection during an overshoot and correction.

 (3) Reduce ssthresh to the peer's declared receive window.

 (4) The offset field in rxrpc_skb_priv can be dispensed with and the error
     field is no longer used.  Get rid of them.

 (5) Keep the call timeouts as ktimes rather than jiffies to make it easier
     to deal with RTT-based timeout values in future.  Rounding to jiffies
     is still necessary when the system timer is set.

 (6) Fix the call timer handling to avoid retriggering of expired timeout
     actions.

The patches can be found here also:

	http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/log/?h=rxrpc-rewrite

Tagged thusly:

	git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git
	rxrpc-rewrite-20160930

David
---
David Howells (7):
      rxrpc: Actually display the tx_data trace retransmission note
      rxrpc: Switch to Congestion Avoidance mode at cwnd==ssthresh
      rxrpc: Reduce ssthresh to peer's receive window
      rxrpc: The offset field in struct rxrpc_skb_priv is unnecessary
      rxrpc: Remove error from struct rxrpc_skb_priv as it is unused
      rxrpc: Keep the call timeouts as ktimes rather than jiffies
      rxrpc: Fix the call timer handling


 include/trace/events/rxrpc.h |   28 +++++++-------
 net/rxrpc/ar-internal.h      |   10 ++---
 net/rxrpc/call_event.c       |   87 +++++++++++++++++++++++++-----------------
 net/rxrpc/call_object.c      |   19 +++------
 net/rxrpc/conn_event.c       |    3 +
 net/rxrpc/input.c            |   34 +++++++++-------
 net/rxrpc/local_event.c      |    3 +
 net/rxrpc/misc.c             |   15 +++++--
 net/rxrpc/recvmsg.c          |    6 +--
 net/rxrpc/rxkad.c            |    9 +++-
 net/rxrpc/sendmsg.c          |    8 ++--
 net/rxrpc/sysctl.c           |    8 ++--
 12 files changed, 125 insertions(+), 105 deletions(-)
