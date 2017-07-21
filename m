From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 0/2] rxrpc: Rearrange headers
Date: Fri, 21 Jul 2017 19:29:42 +0100
Message-ID: <150066178283.18902.5185801865257802317.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Here's a pair of patches that rearrange some of the AF_RXRPC header files
that are outside of the net/rxrpc/ directory:

 (1) The bits userspace need are moved to uapi/linux/rxrpc.h.  [Should this
     be af_rxrpc.h instead, I wonder - but there doesn't seem to be
     precedent for that in the other net UAPI headers.]

 (2) For the most part, the contents of rxrpc/packet.h are no longer used
     outside of the AF_RXRPC module, so move them to net/rxrpc/protocol.h
     with the exception of the standard abort codes which are exposed to
     userspace when an abort occurs and the security index values which are
     needed when constructing keys.

The patches can be found here also:

	http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/log/?h=rxrpc-rewrite

Tagged thusly:

	git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git
	rxrpc-rewrite-20170721

David
---
David Howells (2):
      rxrpc: Expose UAPI definitions to userspace
      rxrpc: Move the packet.h include file into net/rxrpc/


 fs/afs/misc.c              |    1 
 fs/afs/rxrpc.c             |    1 
 include/linux/rxrpc.h      |   79 ---------------
 include/rxrpc/packet.h     |  235 --------------------------------------------
 include/uapi/linux/rxrpc.h |  124 +++++++++++++++++++++++
 net/rxrpc/ar-internal.h    |    2 
 net/rxrpc/protocol.h       |  190 ++++++++++++++++++++++++++++++++++++
 7 files changed, 315 insertions(+), 317 deletions(-)
 delete mode 100644 include/linux/rxrpc.h
 delete mode 100644 include/rxrpc/packet.h
 create mode 100644 include/uapi/linux/rxrpc.h
 create mode 100644 net/rxrpc/protocol.h
