From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 0/8] rxrpc: Preparation for removal of use of skbs
 from AFS
Date: Tue, 30 Aug 2016 16:41:37 +0100
Message-ID: <147257169706.6391.3116382288289485794.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44318 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754557AbcH3Plj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 30 Aug 2016 11:41:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Here's a set of patches that prepare the way for the removal of the use of
sk_buffs from fs/afs (they'll be entirely retained within net/rxrpc):

 (1) Fix a potential NULL-pointer deref in rxrpc_abort_calls().

 (2) Condense all the terminal call state machine states to a single one
     plus supplementary info.

 (3) Add a trace point for rxrpc call usage debugging.

 (4) Cleanups and missing headers.

 (5) Provide a way for AFS to ask about a call's peer address without
     having an sk_buff to query.

 (6) Use call->peer directly rather than going via call->conn (which might
     be NULL).

 (7) Pass struct socket * to various rxrpc kernel interface functions so
     they can use that directly rather than getting it from the rxrpc_call
     struct.

The patches can be found here also (non-terminally on the branch):

	http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/log/?h=rxrpc-rewrite

Tagged thusly:

	git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git
	rxrpc-rewrite-20160830-1

David
---
David Howells (8):
      rxrpc: Fix a potential NULL-pointer deref in rxrpc_abort_calls
      rxrpc: Calls should only have one terminal state
      rxrpc: Trace rxrpc_call usage
      afs: Miscellaneous simple cleanups
      afs: Need linux/random.h
      rxrpc: Provide a way for AFS to ask for the peer address of a call
      rxrpc: Use call->peer rather than going to the connection
      rxrpc: Pass struct socket * to more rxrpc kernel interface functions


 Documentation/networking/rxrpc.txt |   18 ++++-
 fs/afs/cmservice.c                 |   26 +++----
 fs/afs/internal.h                  |    5 +
 fs/afs/main.c                      |    1 
 fs/afs/rxrpc.c                     |   28 ++++---
 fs/afs/server.c                    |   11 ++-
 include/net/af_rxrpc.h             |   12 ++-
 include/trace/events/rxrpc.h       |   39 ++++++++++
 net/rxrpc/af_rxrpc.c               |    5 +
 net/rxrpc/ar-internal.h            |  135 +++++++++++++++++++++++++-----------
 net/rxrpc/call_accept.c            |   24 ++----
 net/rxrpc/call_event.c             |   63 +++++++----------
 net/rxrpc/call_object.c            |  133 +++++++++++++++++++++++++++--------
 net/rxrpc/conn_client.c            |    3 +
 net/rxrpc/conn_event.c             |   53 ++++++++------
 net/rxrpc/conn_object.c            |    4 +
 net/rxrpc/input.c                  |   72 ++++++++++---------
 net/rxrpc/output.c                 |   48 ++++++-------
 net/rxrpc/peer_event.c             |   25 +++++--
 net/rxrpc/peer_object.c            |   15 ++++
 net/rxrpc/proc.c                   |    3 -
 net/rxrpc/recvmsg.c                |   13 ++-
 net/rxrpc/skbuff.c                 |    4 -
 23 files changed, 470 insertions(+), 270 deletions(-)
