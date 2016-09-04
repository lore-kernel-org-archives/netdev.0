From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 0/9] rxrpc: Small fixes
Date: Sun, 04 Sep 2016 22:02:24 +0100
Message-ID: <147302294435.28597.15007422228950187972.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Here's a set of small fix patches:

 (1) Fix some uninitialised variables.

 (2) Set the client call state before making it live by attaching it to the
     conn struct.

 (3) Randomise the epoch and starting client conn ID values, and don't
     change the epoch when the client conn ID rolls round.

 (4) Replace deprecated create_singlethread_workqueue() calls.

The patches can be found here also (non-terminally on the branch):

	http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/log/?h=rxrpc-rewrite

Tagged thusly:

	git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git
	rxrpc-rewrite-20160904-1

David
---
Arnd Bergmann (1):
      rxrpc: fix undefined behavior in rxrpc_mark_call_released

Bhaktipriya Shridhar (4):
      fs/afs/vlocation: Remove deprecated create_singlethread_workqueue
      fs/afs/rxrpc: Remove deprecated create_singlethread_workqueue
      fs/afs/callback: Remove deprecated create_singlethread_workqueue
      fs/afs/flock: Remove deprecated create_singlethread_workqueue

David Howells (4):
      rxrpc: Fix uninitialised variable warning
      rxrpc: The client call state must be changed before attachment to conn
      rxrpc: Randomise epoch and starting client conn ID values
      rxrpc: Don't change the epoch


 fs/afs/callback.c       |    4 ++--
 fs/afs/flock.c          |    4 ++--
 fs/afs/rxrpc.c          |    2 +-
 fs/afs/vlocation.c      |    4 ++--
 include/rxrpc/packet.h  |    1 +
 net/rxrpc/af_rxrpc.c    |    9 ++++++++-
 net/rxrpc/call_event.c  |    5 ++---
 net/rxrpc/call_object.c |    4 +---
 net/rxrpc/conn_client.c |   36 ++++++++++++------------------------
 9 files changed, 31 insertions(+), 38 deletions(-)
