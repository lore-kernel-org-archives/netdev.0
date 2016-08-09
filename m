From: David Howells <dhowells@redhat.com>
Subject: [PATCH net 0/6] rxrpc: Miscellaneous fixes
Date: Tue, 09 Aug 2016 17:33:12 +0100
Message-ID: <147076039224.13232.8512451280294417362.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi Dave,

Here are a bunch of miscellaneous fixes to AF_RXRPC:

 (*) Fix an uninitialised pointer.

 (*) Fix error handling when we fail to connect a call.

 (*) Fix a NULL pointer dereference.

 (*) Fix two occasions where a packet is accessed again after being queued
     for someone else to deal with.

 (*) Fix a missing skb free.

---
The patches can be found here also:

	http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/log/?h=rxrpc-fixes

Tagged thusly:

	git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git
	rxrpc-fixes-20160809

David
---
Arnd Bergmann (1):
      rxrpc: fix uninitialized pointer dereference in debug code

David Howells (5):
      rxrpc: Need to flag call as being released on connect failure
      rxrpc: Don't access connection from call if pointer is NULL
      rxrpc: Once packet posted in data_ready, don't retry posting
      rxrpc: Fix a use-after-push in data_ready handler
      rxrpc: Free packets discarded in data_ready


 net/rxrpc/call_event.c  |    4 ++++
 net/rxrpc/call_object.c |    3 +++
 net/rxrpc/input.c       |   27 ++++++++++++++++-----------
 3 files changed, 23 insertions(+), 11 deletions(-)
