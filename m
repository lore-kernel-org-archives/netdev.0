From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 0/3] rxrpc: Update tracing and proc interfaces
Date: Thu, 05 Jan 2017 14:31:50 +0000
Message-ID: <148362671062.31085.13249164388796003311.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51892 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1030318AbdAEObw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 5 Jan 2017 09:31:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This set of patches fixes and extends tracing:

 (1) Fix the handling of enum-to-string translations so that external
     tracing tools can make use of it by using TRACE_DEFINE_ENUM.

 (2) Extend a couple of tracepoints to export some extra available
     information and add three new tracepoints to allow monitoring of
     received DATA packets, call disconnection and improper/implicit call
     termination.

and adds a bit more procfs-exported information:

 (3) Show a call's hard-ACK cursors in /proc/net/rxrpc_calls.

The patches can be found here also:

	http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/log/?h=rxrpc-rewrite

Tagged thusly:

	git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git
	rxrpc-rewrite-20170105

David
---
David Howells (3):
      rxrpc: Fix handling of enums-to-string translation in tracing
      rxrpc: Add some more tracing
      rxrpc: Show a call's hard-ACK cursors in /proc/net/rxrpc_calls


 include/trace/events/rxrpc.h |  518 ++++++++++++++++++++++++++++++++++++++++--
 net/rxrpc/ar-internal.h      |  194 ----------------
 net/rxrpc/call_object.c      |   18 -
 net/rxrpc/conn_client.c      |    8 -
 net/rxrpc/conn_object.c      |    1 
 net/rxrpc/input.c            |   16 -
 net/rxrpc/misc.c             |  151 ------------
 net/rxrpc/proc.c             |    9 +
 8 files changed, 505 insertions(+), 410 deletions(-)
