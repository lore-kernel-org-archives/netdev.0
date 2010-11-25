From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: [PATCH 0/2] New jhash function
Date: Thu, 25 Nov 2010 14:15:06 +0100
Message-ID: <1290690908-794-1-git-send-email-kadlec@blackhole.kfki.hu>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Linus Torvalds <torvalds@osdl.org>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
To: linux-kernel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Please consider applying the following patch:

The current jhash.h implements the lookup2() hash function by Bob Jenkins. 
However, lookup2() is outdated as Bob wrote a new hash function called 
lookup3(). The new hash function

- mixes better than lookup2(): it passes the check that every input bit 
  changes every output bit 50% of the time, while lookup2() failed it.
- performs better: compiled with -O2 on Core2 Duo, lookup3() 20-40% faster
  than lookup2() depending on the key length.

You can read a longer comparison of the two and other hash functions at 
http://burtleburtle.net/bob/hash/doobs.html.

jhash is widely used in the kernel and because the functions
are inlined, the cost in size is significant. The new functions
are slightly larger than the previous ones so the new implementation
uses non-inlined fucntions. (See
http://lkml.indiana.edu/hypermail//linux/kernel/0902.2/01149.html).
Therefore the first patch replaces the calls to the internal macros
of jhash with the jhash function calls and the second patch contains
the implementation of the new jhash functions.

Jozsef Kadlecsik (2):
  Prepare the tree for un-inlined jhash.
  The new jhash implementation

 include/linux/jhash.h            |  136 ++-------------------------------
 lib/Makefile                     |    2 +-
 lib/jhash.c                      |  153 ++++++++++++++++++++++++++++++++++++++
 net/ipv6/inet6_connection_sock.c |   18 ++---
 net/ipv6/reassembly.c            |   36 ++++-----
 5 files changed, 186 insertions(+), 159 deletions(-)
 create mode 100644 lib/jhash.c

