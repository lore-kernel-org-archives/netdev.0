From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 0/6] rxrpc: Fixes and adjustments
Date: Thu, 29 Sep 2016 23:15:27 +0100
Message-ID: <147518732742.29235.11597637573731081178.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This set of patches contains some fixes and adjustments:

 (1) Connections for exclusive calls are being reused because the check to
     work out whether to set RXRPC_CONN_DONT_REUSE is checking where the
     parameters will be copied to (but haven't yet).

 (2) Make Tx loss-injection go through the normal return, so the state gets
     set correctly for what the code thinks it has done.

     Note lost Tx packets in the tx_data trace rather than the skb
     tracepoint.

 (3) Activate channels according to the current state from within the
     channel_lock to avoid someone changing it on us.

 (4) Reduce the local endpoint's services list to a single pointer as we
     don't allow service AF_RXRPC sockets to share UDP ports with other
     AF_RXRPC sockets, so there can't be more than one element in the list.

 (5) Request more ACKs in slow-start mode to help monitor the state driving
     the window configuration.

 (6) Display the serial number of the packet being ACK'd rather than the
     ACK packet's own serial number in the congestion trace as this can be
     related to other entries in the trace.

The patches can be found here also:

	http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/log/?h=rxrpc-rewrite

Tagged thusly:

	git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git
	rxrpc-rewrite-20160929

David
---
David Howells (6):
      rxrpc: Fix exclusive client connections
      rxrpc: Make Tx loss-injection go through normal return and adjust tracing
      rxrpc: When activating client conn channels, do state check inside lock
      rxrpc: Reduce the rxrpc_local::services list to a pointer
      rxrpc: Request more ACKs in slow-start mode
      rxrpc: Note serial number being ACK'd in the congestion management trace


 include/trace/events/rxrpc.h |    6 ++++--
 net/rxrpc/af_rxrpc.c         |   21 ++++++++-------------
 net/rxrpc/ar-internal.h      |    6 ++----
 net/rxrpc/call_accept.c      |    8 ++++----
 net/rxrpc/call_event.c       |    2 +-
 net/rxrpc/conn_client.c      |   38 ++++++++++++++++++++++++++------------
 net/rxrpc/input.c            |    8 ++++----
 net/rxrpc/local_object.c     |    3 +--
 net/rxrpc/misc.c             |    1 -
 net/rxrpc/output.c           |   18 ++++++++++--------
 net/rxrpc/security.c         |    8 ++++----
 net/rxrpc/sendmsg.c          |    2 +-
 net/rxrpc/skbuff.c           |   11 +++--------
 13 files changed, 68 insertions(+), 64 deletions(-)
