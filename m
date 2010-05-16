From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Sun, 16 May 2010 01:32:39 -0700 (PDT)
Message-ID: <20100516.013239.180390751.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) The new SR-IOV VF netlink messages had a critical error in their
   design, they were not designed to be symmetric (therefore you can't
   take a netlink message dump, and use the elements to recreate
   configurations like you can with other netlink message types).

   Cure this by using nested netlink attributes.

   Better to fix this before it appears in a released kernel.

   Fix from Chris Wright.

2) The per-cpu TCP md5 signature state was not properly softirq
   protected, leading to all kinds of corruptions.  Fix from Eric
   Dumazet.

3) SCTP transport teardown can leave a timer running, fix from Wei
   Yongjun.

Please pull, thanks!

The following changes since commit 4fc4c3ce0dc1096cbd0daa3fe8f6905cbec2b87e:
  Linus Torvalds (1):
        Merge branch 'for-linus' of git://git.infradead.org/users/eparis/notify

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Chris Wright (1):
      rtnetlink: make SR-IOV VF interface symmetric

Eric Dumazet (1):
      tcp: fix MD5 (RFC2385) support

Wei Yongjun (1):
      sctp: delete active ICMP proto unreachable timer when free transport

 include/linux/if_link.h |   23 ++++++-
 include/net/tcp.h       |   21 +-----
 net/core/rtnetlink.c    |  159 ++++++++++++++++++++++++++++++++--------------
 net/ipv4/tcp.c          |   34 +++++++---
 net/sctp/transport.c    |    4 +
 5 files changed, 160 insertions(+), 81 deletions(-)
