From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 0/2] rxrpc: More fixes
Date: Wed, 24 Aug 2016 15:59:46 +0100
Message-ID: <147205078637.13418.9976056129378485689.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Here are a couple of fix patches:

 (1) Fix the conn-based retransmission patch posted yesterday.  This breaks
     if it actually has to retransmit.  However, it seems the likelihood of
     this happening is really low, despite the server I'm testing against
     being located >3000 miles away, and sometime of the time it's handled
     in the call background processor before we manage to disconnect the
     call - hence why I didn't spot it.

 (2) /proc/net/rxrpc_calls can cause a crash it accessed whilst a call is
     being torn down.  The window of opportunity is pretty small, however,
     as calls don't stay in this state for long.

The patches can be found here also (non-terminally on the branch):

	http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/log/?h=rxrpc-rewrite

Tagged thusly:

	git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git
	rxrpc-rewrite-20160824-1

David
---
David Howells (2):
      rxrpc: Fix conn-based retransmit
      rxrpc: Make /proc/net/rxrpc_calls safer


 net/rxrpc/ar-internal.h |    4 +++-
 net/rxrpc/call_object.c |    3 +++
 net/rxrpc/conn_client.c |    1 +
 net/rxrpc/conn_event.c  |    1 +
 net/rxrpc/input.c       |    2 +-
 net/rxrpc/proc.c        |   27 +++++++++++++++++++--------
 6 files changed, 28 insertions(+), 10 deletions(-)
