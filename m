From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Mon, 18 Jul 2011 13:18:13 -0700 (PDT)
Message-ID: <20110718.131813.1898495363509638037.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


A few last-minute stragglers.  The Tulip debug message thing, in
particular, is a really annoying regression for people who have
that hardware.

1) pr_*() conversion of tulip driver turned some commented out messages
   into pr_debug() which spams the log, just kill them off.  From Joe
   Perches.

2) PPPOE connections are keyed on MAC address, so we have to flush all
   connections on a device when the MAC address changes since until we
   renegotiate with the new MAC address the remote end won't see any
   of our packets.

3) linux/sdla.h has a kernel function declaration in the userspace
   visible area.  In fact this function hasn't been in the kernel for
   years so just remove it outright.  From WANG Cong.

Please pull, thanks a lot.

The following changes since commit dc6b845044ccb7e9e6f3b7e71bd179b3cf0223b6:

  si4713-i2c: avoid potential buffer overflow on si4713 (2011-07-18 09:12:21 -0700)

are available in the git repository at:
  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

David S. Miller (1):
      pppoe: Must flush connections when MAC address changes too.

Joe Perches (1):
      tulip: dmfe: Remove old log spamming pr_debugs

WANG Cong (1):
      include/linux/sdla.h: remove the prototype of sdla()

 drivers/net/pppoe.c      |    3 ++-
 drivers/net/tulip/dmfe.c |    4 ----
 include/linux/sdla.h     |    6 +-----
 3 files changed, 3 insertions(+), 10 deletions(-)
