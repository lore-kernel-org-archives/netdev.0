From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Wed, 21 Oct 2009 21:56:41 -0700 (PDT)
Message-ID: <20091021.215641.125478092.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752845AbZJVE4U@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Add some diagnostics so we can try to track down the tcp MSG_PEEK
   WARN_ON that shows up in Arjan's kerneloops list a lot.  From
   Herbert Xu.

2) Bluetooth bug fixes from Dave Young.

3) Fix the DEFER_ACCEP ack counting issue in a better way, from Julian
   Anastasov.

4) be2net bug fixes from Sathya Perla.

5) ethoc bug fixes from Thomas Chou

6) AF_UNIX deadlock on half-close, fix fro Tomoki Sekiyama.

7) virtio_net fix for netconsole from Eric Dumazet.

8) IP_MULTICAST_IF uses __dev_get_by_index() without proper locking.
   From Eric Dumazet.

9) KS8851 bug fixes from Ben Dooks.

Please pull, thanks a lot!

The following changes since commit 2fdc246aaf9a7fa088451ad2a72e9119b5f7f029:
  Linus Torvalds (1):
        Merge branch 'for-linus' of git://git.kernel.org/.../bp/bp

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Ben Dooks (3):
      KS8851: Add soft reset at probe time
      KS8851: Fix MAC address write order
      KS8851: Fix ks8851_set_rx_mode() for IFF_MULTICAST

Dave Young (2):
      bluetooth: scheduling while atomic bug fix
      bluetooth: static lock key fix

David S. Miller (1):
      Revert "tcp: fix tcp_defer_accept to consider the timeout"

Eric Dumazet (3):
      virtio_net: use dev_kfree_skb_any() in free_old_xmit_skbs()
      net: Fix IP_MULTICAST_IF
      net: Fix struct inet_timewait_sock bitfield annotation

Herbert Xu (1):
      tcp: Try to catch MSG_PEEK bug

Joyce Yu (1):
      niu: VLAN_ETH_HLEN should be used to make sure that the whole MAC header was copied to the head buffer in the Vlan packets case

Julian Anastasov (3):
      tcp: accept socket after TCP_DEFER_ACCEPT period
      tcp: reduce SYN-ACK retrans for TCP_DEFER_ACCEPT
      tcp: fix TCP_DEFER_ACCEPT retrans calculation

Randy Dunlap (1):
      vmxnet3: use dev_dbg, fix build for CONFIG_BLOCK=n

Sathya Perla (2):
      be2net: fix promiscuous and multicast promiscuous modes being enabled always
      be2net: fix support for PCI hot plug

Steven King (1):
      net: fix section mismatch in fec.c

Thomas Chou (2):
      ethoc: inline regs access
      ethoc: clear only pending irqs

Tomoki Sekiyama (1):
      AF_UNIX: Fix deadlock on connecting to shutdown socket

 drivers/net/benet/be_cmds.c       |   33 ++++++++++++++-------
 drivers/net/benet/be_cmds.h       |    5 ++-
 drivers/net/benet/be_main.c       |   27 +++++++++-------
 drivers/net/ethoc.c               |   21 +++++++------
 drivers/net/fec.c                 |    2 +-
 drivers/net/ks8851.c              |   42 +++++++++++++++++++++++---
 drivers/net/ks8851.h              |    1 +
 drivers/net/niu.c                 |    2 +-
 drivers/net/virtio_net.c          |    2 +-
 drivers/net/vmxnet3/vmxnet3_drv.c |   27 +++++++++++-----
 drivers/net/vmxnet3/vmxnet3_int.h |    2 +-
 include/net/inet_timewait_sock.h  |    8 ++--
 net/bluetooth/hci_sysfs.c         |    4 +-
 net/bluetooth/l2cap.c             |    9 ++++--
 net/ipv4/inet_connection_sock.c   |   34 +++++++++++++++++++--
 net/ipv4/ip_sockglue.c            |    7 ++--
 net/ipv4/tcp.c                    |   59 ++++++++++++++++++++++++++++--------
 net/ipv4/tcp_minisocks.c          |    5 +--
 net/ipv6/ipv6_sockglue.c          |    6 +++-
 net/unix/af_unix.c                |    2 +
 20 files changed, 212 insertions(+), 86 deletions(-)
