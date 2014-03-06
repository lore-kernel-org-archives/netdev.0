From: David Howells <dhowells@redhat.com>
Subject: [PATCH 0/3] AF_RXRPC fixes [ver #3]
Date: Thu, 06 Mar 2014 23:18:36 +0000
Message-ID: <20140306231835.11431.50147.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, tim@electronghost.co.uk,
	linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi Dave,

Here are some AF_RXRPC fixes:

 (1) Fix to remove incorrect checksum calculation made during recvmsg().  It's
     unnecessary to try to do this there since we check the checksum before
     reading the RxRPC header from the packet.

 (2) Fix to prevent the sending of an ABORT packet in response to another
     ABORT packet and inducing a storm.

 (3) Fix UDP MTU calculation from parsing ICMP_FRAG_NEEDED packets where we
     don't handle the ICMP packet not specifying an MTU size.

---
The above changes since commit c88507fbad8055297c1d1e21e599f46960cbee39:

  ipv6: don't set DST_NOCOUNT for remotely added routes (2014-03-06 17:29:27 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git tags/rxrpc-fixes-20140306

for you to fetch changes up to ddc348e1c88d705b70f8aba0c42876100277c829:

  af_rxrpc: Fix UDP MTU calculation from ICMP_FRAG_NEEDED (2014-03-06 23:01:50 +0000)

David
---
David Howells (1):
      af_rxrpc: Fix UDP MTU calculation from ICMP_FRAG_NEEDED

Tim Smith (2):
      af_rxrpc: Remove incorrect checksum calculation from rxrpc_recvmsg()
      af_rxrpc: Prevent RxRPC peers from ABORT-storming one another


 net/rxrpc/ar-error.c   |    1 +
 net/rxrpc/ar-input.c   |   12 ++++++++----
 net/rxrpc/ar-recvmsg.c |   25 +------------------------
 3 files changed, 10 insertions(+), 28 deletions(-)
