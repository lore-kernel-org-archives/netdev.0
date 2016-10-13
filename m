From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 0/4] rxrpc: Fixes
Date: Thu, 13 Oct 2016 17:12:09 +0100
Message-ID: <147637512988.17348.9857198849984467857.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        dan.carpenter@oracle.com, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47078 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933052AbcJMQOk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 13 Oct 2016 12:14:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This set of patches contains a bunch of fixes:

 (1) Fix use of kunmap() after change from kunmap_atomic() within AFS.

 (2) Don't use of ERR_PTR() with an always zero value.

 (3) Check the right error when using ip6_route_output().

 (4) Be consistent about whether call->operation_ID is BE or CPU-E within
     AFS.

The patches can be found here also:

	http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/log/?h=rxrpc-rewrite

Tagged thusly:

	git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git
	rxrpc-rewrite-20161013

David
---
Dan Carpenter (1):
      afs: unmapping the wrong buffer

David Howells (3):
      rxrpc: Fix checker warning by not passing always-zero value to ERR_PTR()
      rxrpc: Fix checking of error from ip6_route_output()
      afs: call->operation_ID sometimes used as __be32 sometimes as u32


 fs/afs/cmservice.c      |    6 ++----
 fs/afs/fsclient.c       |    4 ++--
 fs/afs/internal.h       |    2 +-
 fs/afs/rxrpc.c          |    3 ++-
 net/rxrpc/call_object.c |    2 +-
 net/rxrpc/peer_object.c |    4 ++--
 6 files changed, 10 insertions(+), 11 deletions(-)
