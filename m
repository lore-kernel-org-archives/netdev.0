From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Thu, 18 Sep 2008 19:28:12 -0700 (PDT)
Message-ID: <20080918.192812.160946387.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49646
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753010AbYISC2Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2008 22:28:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) bnx2 records MSI vector as 16-bit value, which breaks due to
   2.6.27 io_apic.c changes on x86, use 32-bit value instead.
   From Benjamin Li.

2) Due to missing locking, EEPROM/NVRAM can be corrupted making
   the card subsequently nearly unusable.  Fix from Christopher Li.

3) UDP receive path can try to recursively lock a socket and
   deadlock, regression from 2.6.26  Reported by lockdep and
   fixed by Herbert Xu.

4) Three SCTP fixes from Vlad Yasevich:
   a) OOPS when processing INIT-ACK packets
   b) SCTP can advertise features it doesn't even support
   c) SCTP stopped working over loopback due to some checksumming
      changes in 2.6.27

5) e100 needs to use pci_pme_active, from Yinghai Lu.  This is on
   the regression list.

6) MAC address not properly restored during shutdown in forcedeth
   driver, Yinghai Lu.  This is on the regression list.

Please pull, thanks a lot.

The following changes since commit cff502a38394fd33693f6233e03fca363dfa956d:
  Santwona Behera (1):
        niu: panic on reset

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Benjamin Li (1):
      bnx2: Promote vector field in bnx2_irq structure from u16 to unsigned int

Christopher Li (1):
      e1000: prevent corruption of EEPROM/NVM

Herbert Xu (1):
      udp: Fix rcv socket locking

Rafael J. Wysocki (1):
      e100: Use pci_pme_active to clear PME_Status and disable PME#

Vlad Yasevich (3):
      sctp: set the skb->ip_summed correctly when sending over loopback.
      sctp: do not enable peer features if we can't do them.
      sctp: Fix oops when INIT-ACK indicates that peer doesn't support AUTH

Yinghai Lu (1):
      forcedeth: call restore mac addr in nv_shutdown path

 drivers/net/bnx2.h           |    2 +-
 drivers/net/e100.c           |    4 +--
 drivers/net/e1000/e1000_hw.c |   23 +++++++++++++++
 drivers/net/forcedeth.c      |   16 +++++++++--
 net/ipv4/udp.c               |   62 ++++++++++++++++++++++-------------------
 net/sctp/associola.c         |    9 +++---
 net/sctp/output.c            |    3 +-
 net/sctp/sm_make_chunk.c     |   15 ++++++----
 8 files changed, 87 insertions(+), 47 deletions(-)
