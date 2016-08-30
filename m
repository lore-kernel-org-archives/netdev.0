From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next] rxrpc: Remove use of skbs from AFS
Date: Tue, 30 Aug 2016 16:52:32 +0100
Message-ID: <147257235268.6716.12062621584578937716.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Here's a single patch that removes the use of sk_buffs from fs/afs.  From
this point on they'll be entirely retained within net/rxrpc and AFS just
asks AF_RXRPC for linear buffers of data.  This needs to be applied on top
of the just-posted preparatory patch set.

This makes some future developments easier/possible:

 (1) Simpler rxrpc_call usage counting.

 (2) Earlier freeing of metadata sk_buffs.

 (3) Rx phase shortcutting on abort/error.

 (4) Encryption/decryption in the AFS fs contexts/threads and directly
     between sk_buffs and AFS buffers.

 (5) Synchronous waiting in reception for AFS.

The patch can be found here also:

	http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/log/?h=rxrpc-rewrite

Tagged thusly:

	git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git
	rxrpc-rewrite-20160830-2

David
---
David Howells (1):
      rxrpc: Don't expose skbs to in-kernel users


 Documentation/networking/rxrpc.txt |   72 +++---
 fs/afs/cmservice.c                 |  142 ++++++------
 fs/afs/fsclient.c                  |  148 +++++-------
 fs/afs/internal.h                  |   34 +--
 fs/afs/rxrpc.c                     |  439 +++++++++++++-----------------------
 fs/afs/vlclient.c                  |    7 -
 include/net/af_rxrpc.h             |   35 +--
 net/rxrpc/af_rxrpc.c               |   29 +-
 net/rxrpc/ar-internal.h            |   23 ++
 net/rxrpc/call_accept.c            |   13 +
 net/rxrpc/call_object.c            |    5 
 net/rxrpc/conn_event.c             |    1 
 net/rxrpc/input.c                  |   10 +
 net/rxrpc/output.c                 |    2 
 net/rxrpc/recvmsg.c                |  195 +++++++++++++---
 net/rxrpc/skbuff.c                 |    1 
 16 files changed, 570 insertions(+), 586 deletions(-)
