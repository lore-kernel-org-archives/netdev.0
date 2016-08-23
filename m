From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 0/5] rxrpc: Cleanups
Date: Tue, 23 Aug 2016 16:26:18 +0100
Message-ID: <147196597852.28271.4071308846084923450.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Here are some cleanups for the AF_RXRPC rewrite:

 (1) Remove some unused bits.

 (2) Call releasing on socket closure is now done in the order in which
     calls progress through the phases so that we don't miss a call
     actively moving list.

 (3) The rxrpc_call struct's channel number field is redundant and replaced
     with accesses to the masked off cid field instead.

 (4) Use a tracepoint for socket buffer accounting rather than printks.

     Unfortunately, since this would require currently non-existend
     arch-specific help to divine the current instruction location, the
     accounting functions are moved out of line so that
     __builtin_return_address() can be used.

The patches can be found here also (though they're not terminal on the branch):

	http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/log/?h=rxrpc-rewrite

Tagged thusly:

	git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git
	rxrpc-rewrite-20160823-1

David
---
David Howells (5):
      rxrpc: Remove RXRPC_CALL_PROC_BUSY
      rxrpc: Tidy up the rxrpc_call struct a bit
      rxrpc: When clearing a socket, clear the call sets in the right order
      rxrpc: Drop channel number field from rxrpc_call struct
      rxrpc: Use a tracepoint for skb accounting debugging


 include/trace/events/rxrpc.h |   56 +++++++++++++++++++++++++++++++++++
 net/rxrpc/af_rxrpc.c         |    1 +
 net/rxrpc/ar-internal.h      |   68 +++++++++++++-----------------------------
 net/rxrpc/call_accept.c      |    1 +
 net/rxrpc/call_event.c       |    9 ++----
 net/rxrpc/call_object.c      |   26 ++++++----------
 net/rxrpc/conn_client.c      |    2 -
 net/rxrpc/conn_event.c       |    2 +
 net/rxrpc/conn_object.c      |    5 ++-
 net/rxrpc/local_event.c      |    1 +
 net/rxrpc/output.c           |    5 ++-
 net/rxrpc/proc.c             |    6 ++--
 net/rxrpc/recvmsg.c          |    1 +
 net/rxrpc/rxkad.c            |    4 +-
 net/rxrpc/skbuff.c           |   62 ++++++++++++++++++++++++++++++++++++++
 15 files changed, 169 insertions(+), 80 deletions(-)
 create mode 100644 include/trace/events/rxrpc.h
