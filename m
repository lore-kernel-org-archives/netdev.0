From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Sat, 30 Oct 2010 18:32:57 -0700 (PDT)
Message-ID: <20101030.183257.70183832.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51125
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754503Ab0JaBce (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Oct 2010 21:32:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Last pull request before 2.6.37-rc1, I really wanted to get your
sendto/recvfrom patch in here as well as the RDS fixes.

I did a bunch of tests with the various I/O calls using different
lengths, like 10, (2^31 - 1), 2^31, 2^32, and larger on 64-bit and it
all seems to be doing the right thing at least with TCP and UDP.

Also:

1) Fix ipv6 UDP statistic regression, from Eric Dumazet.

2) Fix GRE fallback tunnel init, also from Eric Dumazet.

3) Endianness fixes from vmxnet driver, from Harvey Harrison.

4) New ID for pcnet_cs driver.

5) Stack info leak to userland fix in mISDN, from Kulikov Vasiliy.

6) netxen_nic probe crash due to too early tx queue manipulation,
   fix from Denis Kirjanov.

7) RDS fixes from you and Andy Grover.

8) Fix sparse and section mismatch problems in new pch_can driver,
   from Marc Kleine-Budde.

Please pull, thanks a lot!

The following changes since commit b7bdcc47114595b4b359fe0f7d941bb901e9261d:

  Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/rostedt/linux-2.6-kconfig (2010-10-29 14:43:30 -0700)

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Andy Grover (4):
      RDS: Return -EINVAL if rds_rdma_pages returns an error
      RDS: Clean up error handling in rds_cmsg_rdma_args
      RDS: Copy rds_iovecs into kernel memory instead of rereading from userspace
      RDS: Let rds_message_alloc_sgs() return NULL

Cyril Chemparathy (1):
      phy/marvell: rename 88ec048 to 88e1318s and fix mscr1 addr

Denis Kirjanov (1):
      netxen_nic: Fix the tx queue manipulation bug in netxen_nic_probe

Eric Dumazet (2):
      ipv6/udp: report SndbufErrors and RcvbufErrors
      ip_gre: fix fallback tunnel setup

Hans J. Koch (1):
      netdev: can: Change mail address of Hans J. Koch

Harvey Harrison (2):
      vmxnet3: remove unnecessary byteswapping in BAR writing macros
      vmxnet: trivial annotation of protocol constant

Ken Kawasaki (1):
      pcnet_cs: add new_id

Kulikov Vasiliy (1):
      isdn: mISDN: socket: fix information leak to userland

Linus Torvalds (2):
      net: fix rds_iovec page count overflow
      net: Truncate recvfrom and sendto length to INT_MAX.

Marc Kleine-Budde (2):
      can: pch_can: fix sparse warning
      can: pch_can: fix section mismatch warning by using a whitelisted name

 drivers/isdn/mISDN/socket.c          |    2 +
 drivers/net/can/at91_can.c           |    2 +-
 drivers/net/can/pch_can.c            |   10 ++--
 drivers/net/netxen/netxen_nic_main.c |    1 -
 drivers/net/pcmcia/pcnet_cs.c        |    1 +
 drivers/net/phy/marvell.c            |   18 +++---
 drivers/net/vmxnet3/vmxnet3_drv.c    |    2 +-
 drivers/net/vmxnet3/vmxnet3_int.h    |    8 +-
 include/linux/marvell_phy.h          |    2 +-
 net/ipv4/ip_gre.c                    |    6 +-
 net/ipv6/proc.c                      |    4 +
 net/rds/message.c                    |    5 ++
 net/rds/rdma.c                       |  126 ++++++++++++++++++++++-----------
 net/rds/send.c                       |    4 +
 net/socket.c                         |    4 +
 15 files changed, 128 insertions(+), 67 deletions(-)
