From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Wed, 06 Aug 2014 20:20:33 -0700 (PDT)
Message-ID: <20140806.202033.1754746291270267193.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This fixes the most immediate fallout from yesterday's networking
merge.

1) sock_tx_timestamp() must not clear the passed in tx_flags, but rather
   add to them.  Fix from Eric Dumazet.

2) The hyperv driver sendbuf region increase needs to be decreased
   slightly to handle older backends.  From KY Srinivasan.

3) Fix RCU lockdep splats in netlink diag after recent hashing changes,
   from Thomas Graf.

4) The new IPV6_FLOWLABEL was given a socket option number that
   overlapped with an existing IP6 tables one, breaking ip6_tables.
   Fixed by Pablo Neira Ayuso.

Please pull, thanks a lot!

The following changes since commit 85417aef44fc58b08773117ceb1bc6ca5684e973:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/ide (2014-08-06 09:42:33 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to 6c8f7e70837468da4e658080d4448930fb597e1b:

  netlink: hold nl_sock_hash_lock during diag dump (2014-08-06 19:17:44 -0700)

----------------------------------------------------------------
Dmitry Popov (1):
      tcp: md5: check md5 signature without socket lock

Eric Dumazet (1):
      net-timestamp: sock_tx_timestamp() fix

Francois Romieu (1):
      net: fix USB network driver config option.

Hans Wennborg (1):
      vmxnet3: fix decimal printf format specifiers prefixed with 0x

Hariprasad Shenai (1):
      cxgb4: Fix for SR-IOV VF initialization

KY Srinivasan (1):
      hyperv: Adjust the size of sendbuf region to support ws2008r2

Pablo Neira (1):
      net: reallocate new socket option number for IPV6_AUTOFLOWLABEL

Thomas Graf (1):
      netlink: hold nl_sock_hash_lock during diag dump

Willem de Bruijn (1):
      net-timestamp: cumulative tcp timestamping fixes

 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |  7 +++----
 drivers/net/hyperv/hyperv_net.h                 |  2 +-
 drivers/net/usb/Kconfig                         |  4 ++--
 drivers/net/vmxnet3/vmxnet3_drv.c               |  2 +-
 drivers/net/wireless/Kconfig                    |  1 +
 include/net/sock.h                              |  6 ++++--
 include/uapi/linux/in6.h                        |  2 +-
 net/ipv4/tcp.c                                  | 12 +++++++-----
 net/ipv4/tcp_ipv4.c                             | 36 +++++++++++++++++++++++++-----------
 net/ipv4/tcp_offload.c                          |  8 ++++----
 net/ipv6/tcp_ipv6.c                             | 25 +++++++++++++++++++------
 net/netlink/af_netlink.c                        |  1 +
 net/netlink/af_netlink.h                        |  1 +
 net/netlink/diag.c                              |  3 +++
 net/socket.c                                    | 20 +++++++++++++-------
 15 files changed, 86 insertions(+), 44 deletions(-)
