From: David Howells <dhowells@redhat.com>
Subject: [PATCH 00/13] RxRPC: Rewrite part 1
Date: Fri, 04 Mar 2016 16:37:05 +0000
Message-ID: <20160304163705.31057.60831.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linux-afs@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Here's the first set of patches from my RxRPC rewrite, aimed at net-next.
These do some clean ups and bug fixes.  Most of the changes are small, but
there are a couple of bigger changes:

 (*) Convert call flag numbers and event numbers into enums.  Then rename
     the event numbers to all have _EV_ in their name to stop confusion.
     Fix one instance of an event bit being used instead of a flag bit.

 (*) A copy of the Rx protocol header is kept in the sk_buff private data.
     Keep this in host byte order rather than network byte order as it
     makes more sense.  A number of other fields then get converted into
     host byte order too.

     Conversion between host and network byte order is then done at the
     packet reception/generation stage.

The patches can be found here also:

	http://git.kernel.org/cgit/linux/kernel/git/dhowells/linux-fs.git/log/?h=rxrpc-rewrite

Tagged thusly:

	git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git
	rxrpc-rewrite-20160304

This is based on net-next/master

David
---
David Howells (13):
      rxrpc: Fix a case where a call event bit is being used as a flag bit
      rxrpc: Convert call flag and event numbers into enums
      rxrpc: Rename call events to begin RXRPC_CALL_EV_
      rxrpc: Keep the skb private record of the Rx header in host byte order
      rxrpc: The protocol family should be set to PF_RXRPC not PF_UNIX
      rxrpc: Fix defined range for /proc/sys/net/rxrpc/rx_mtu
      rxrpc: Be more selective about the types of received packets we accept
      rxrpc: Adjust some whitespace and comments
      rxrpc: Use ACCESS_ONCE() when accessing circular buffer pointers
      rxrpc: rxkad: The version number in the response should be net byte order
      rxrpc: rxkad: Casts are needed when comparing be32 values
      rxrpc: Clear the unused part of a sockaddr_rxrpc for memcmp() use
      rxrpc: Don't try to map ICMP to error as the lower layer already did that


 include/rxrpc/packet.h    |   15 +++
 net/rxrpc/af_rxrpc.c      |   39 +++-----
 net/rxrpc/ar-accept.c     |   56 +++++++-----
 net/rxrpc/ar-ack.c        |  213 ++++++++++++++++++++++-----------------------
 net/rxrpc/ar-call.c       |   84 ++++++++----------
 net/rxrpc/ar-connection.c |   83 ++++++++----------
 net/rxrpc/ar-connevent.c  |   79 ++++++++---------
 net/rxrpc/ar-error.c      |   13 ---
 net/rxrpc/ar-input.c      |  118 ++++++++++++++-----------
 net/rxrpc/ar-internal.h   |  196 ++++++++++++++++++++++++-----------------
 net/rxrpc/ar-local.c      |   29 ++++--
 net/rxrpc/ar-output.c     |   73 ++++++++++-----
 net/rxrpc/ar-peer.c       |    2 
 net/rxrpc/ar-proc.c       |   10 +-
 net/rxrpc/ar-recvmsg.c    |   20 ++--
 net/rxrpc/ar-security.c   |    6 +
 net/rxrpc/ar-skbuff.c     |    7 +
 net/rxrpc/ar-transport.c  |    1 
 net/rxrpc/rxkad.c         |  165 ++++++++++++++++++-----------------
 net/rxrpc/sysctl.c        |    2 
 20 files changed, 639 insertions(+), 572 deletions(-)
