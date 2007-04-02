From: David Howells <dhowells@redhat.com>
Subject: [PATCH 0/9] AF_RXRPC socket family and AFS rewrite
Date: Mon, 02 Apr 2007 23:44:49 +0100
Message-ID: <20070402224449.31568.17833.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, dhowells@redhat.com
To: torvalds@osdl.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:54599 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933674AbXDBWpB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Apr 2007 18:45:01 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The first of these patches together provide secure client-side RxRPC
connectivity as a Linux kernel socket family.  Only the RxRPC transport/session
side is supplied - the presentation side (marshalling the data) is left to the
client.  Copies of the patches can be found here:

	http://people.redhat.com/~dhowells/rxrpc/series
	http://people.redhat.com/~dhowells/rxrpc/01-crypto-kernel-buff.diff
	http://people.redhat.com/~dhowells/rxrpc/02-move-skb-generic.diff
	http://people.redhat.com/~dhowells/rxrpc/03-timers.diff
	http://people.redhat.com/~dhowells/rxrpc/04-keys.diff
	http://people.redhat.com/~dhowells/rxrpc/05-af_rxrpc.diff

Further patches make the in-kernel AFS filesystem use AF_RXRPC and delete the
old RxRPC implementation:

	http://people.redhat.com/~dhowells/rxrpc/06-afs-cleanup.diff
	http://people.redhat.com/~dhowells/rxrpc/07-af_rxrpc-kernel.diff
	http://people.redhat.com/~dhowells/rxrpc/08-af_rxrpc-afs.diff
	http://people.redhat.com/~dhowells/rxrpc/09-af_rxrpc-delete-old.diff

The userspace access methods make use of the control data passed to/by
sendmsg() and recvmsg().  See the three simple test programs:

	http://people.redhat.com/~dhowells/rxrpc/klog.c
	http://people.redhat.com/~dhowells/rxrpc/rxrpc.c
	http://people.redhat.com/~dhowells/rxrpc/listen.c

TODO:

 (*) Make certain parameters (such as connection timeouts) userspace
     configurable.

 (*) Make userspace utilities use it; librxrpc.

 (*) Userspace documentation.

 (*) KerberosV security.

Changes:

 (*) SOCK_RPC has been removed.  SOCK_DGRAM is now used instead.

 (*) I've add a facility whereby calls can be made to destinations other than
     the connect() address of a client socket by making use of msg_name in the
     msghdr struct when using sendmsg() to send the first data packet of a
     call.  Indeed, a client socket need not be connected before being used
     so.

 (*) I've also added a facility whereby client calls may also be made on
     server sockets, again by using msg_name in the msghdr struct.  In such a
     case, the server's local transport endpoint is used.

 (*) I've made the write buffer space check available to various callers
     (sk_write_space) and implemented poll support.

 (*) Rewrote rxrpc_recvmsg().  It now concatenates adjacent data messages from
     the same call when delivering them.

 (*) Updated the documentation to include notes on recvmsg, cover control
     messages and cover SOL_RXRPC-level socket options.

 (*) Provided an in-kernel interface to give in-kernel utilities easier access
     to the facility.

 (*) Made fs/afs/ use it.

 (*) Deleted the old contents of net/rxrpc/.

David
