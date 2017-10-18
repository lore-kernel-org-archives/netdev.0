From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 0/3] rxrpc: Add bits for kernel services
Date: Wed, 18 Oct 2017 12:55:50 +0100
Message-ID: <150832775000.7695.7720685597577836060.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Here are some patches that add a few things for kernel services to use:

 (1) Allow service upgrade to be requested and allow the resultant actual
     service ID to be obtained.

 (2) Allow the RTT time of a call to be obtained.

 (3) Allow a kernel service to find out if a call is still alive on a
     server between transmitting a request and getting the reply.

 (4) Allow data transmission to ignore signals if transmission progress is
     being made in reasonable time.  This is also usable by userspace by
     passing MSG_WAITALL to sendmsg()[*].

[*] I'm not sure this is the right interface for this or whether a sockopt
    should be used instead.

The patches can be found here also:

	http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/log/?h=rxrpc-next

Tagged thusly:

	git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git
	rxrpc-next-20171018

David
---
David Howells (3):
      rxrpc: Support service upgrade from a kernel service
      rxrpc: Provide functions for allowing cleaner handling of signals
      rxrpc: Use MSG_WAITALL to tell sendmsg() to temporarily ignore signals


 Documentation/networking/rxrpc.txt |   53 +++++++++++++++++-
 fs/afs/internal.h                  |    1 
 fs/afs/rxrpc.c                     |   42 +++++++++++---
 include/net/af_rxrpc.h             |    7 ++
 net/rxrpc/af_rxrpc.c               |   24 ++++++++
 net/rxrpc/peer_object.c            |   13 ++++
 net/rxrpc/recvmsg.c                |    5 +-
 net/rxrpc/sendmsg.c                |  107 +++++++++++++++++++++++++++---------
 8 files changed, 211 insertions(+), 41 deletions(-)
