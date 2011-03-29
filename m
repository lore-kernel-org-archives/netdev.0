From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Tue, 29 Mar 2011 00:49:40 -0700 (PDT)
Message-ID: <20110329.004940.246541004.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Fix oops in RAW ipv4 when route doesn't exist.

2) Heap corruptions, missing length checks, in IRDA and ROSE.  From
   Dan Rosenberg and Ben Hutchings.

3) Fix FIB error return code checking regression, fix from Julian Anastasov.

4) Fix refression in ethtool ->set_flags() error returns for some
   network drivers, from Stanislaw Gruszka.

5) When we do async crypto, we don't take a reference while the transaction
   is "in flight" and thus can crash if the object is release meanwhile.
   Fix from Steffen Klassert.

6) Bug fixes to the new IPSEC extended replay window support, also
   from Steffen Klassert.

7) Bridge forgets to send out notifier when device address changes, from
   Stephen Hemminger.

8) Conver jme driver away from legacy PCI power management, from Rafael J.
   Wysocki.

9) GRO is ineffective on large page size configs because we don't put
   enough scatter gather elements into the SKB, from Anton Blanchard.

10) cxgb3 erroneously only applies irq coalescing settings to one queue,
    fix also from Anton Blanchard.

11) CAN fixes from Jan Altenberg, Marc Kleine-Budde, and Oliver Hartkopp.

12) mlx4_en driver loses promiscuous setting, fix from Herbert Xu.

Please pull, thanks a lot!

The following changes since commit 89078d572eb9ce8d4c04264b8b0ba86de0d74c8f:

  md: Fix integrity registration error when no devices are capable (2011-03-28 17:53:29 -0700)

are available in the git repository at:
  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Amerigo Wang (1):
      net: remove useless comments in net/core/dev.c

Anton Blanchard (2):
      net: Always allocate at least 16 skb frags regardless of page size
      cxgb3: Apply interrupt coalescing settings to all queues

Balaji G (1):
      drivers net: Fix declaration ordering in inline functions.

Ben Hutchings (1):
      rose: Add length checks to CALL_REQUEST parsing

Cesar Eduardo Barros (1):
      net: use CHECKSUM_NONE instead of magic number

Dan Rosenberg (3):
      irda: prevent heap corruption on invalid nickname
      irda: validate peer name and attribute lengths
      ROSE: prevent heap corruption with bad facilities

David S. Miller (1):
      ipv4: Don't ip_rt_put() an error pointer in RAW sockets.

Herbert Xu (1):
      mlx4_en: Fix loss of promiscuity

Jan Altenberg (1):
      can: c_can: Fix tx_bytes accounting

Jan Luebbe (1):
      ipv4: Fix IP timestamp option (IPOPT_TS_PRESPEC) handling in ip_options_echo()

Javier Martinez Canillas (2):
      tg3: use <linux/io.h> and <linux/uaccess.h> instead <asm/io.h> and <asm/uaccess.h>
      tg3: Fix inline keyword usage

Julian Anastasov (1):
      ipv4: do not ignore route errors

Marc Kleine-Budde (2):
      can: c_can: disable one shot mode until driver is fixed
      can: c_can_platform: fix irq check in probe

Mike Frysinger (1):
      netdev: bfin_mac: document TE setting in RMII modes

Oliver Hartkopp (1):
      can: make struct proto const

Rafael J. Wysocki (1):
      Net / jme: Do not use legacy PCI power management

Stanislaw Gruszka (2):
      myri10ge: small rx_done refactoring
      net: fix ethtool->set_flags not intended -EINVAL return value

Steffen Klassert (6):
      xfrm: Force a dst refcount before entering the xfrm type handlers
      dst: Clone child entry in skb_dst_pop
      xfrm: Move the test on replay window size into the replay check functions
      xfrm: Assign esn pointers when cloning a state
      xfrm: Check for esn buffer len in xfrm_new_ae
      xfrm: Restrict extended sequence numbers to esp

stephen hemminger (1):
      bridge: notify applications if address of bridge device changes

 drivers/net/bfin_mac.c                  |   13 ++++-
 drivers/net/bnx2.c                      |    2 +-
 drivers/net/can/c_can/c_can.c           |   16 ++----
 drivers/net/can/c_can/c_can_platform.c  |    9 ++-
 drivers/net/cxgb3/cxgb3_main.c          |   14 +++-
 drivers/net/jme.c                       |   30 +++++----
 drivers/net/ksz884x.c                   |    2 +-
 drivers/net/mlx4/en_netdev.c            |    3 +
 drivers/net/myri10ge/myri10ge.c         |   37 +++++++----
 drivers/net/netxen/netxen_nic_ethtool.c |    2 +-
 drivers/net/qlcnic/qlcnic_ethtool.c     |    2 +-
 drivers/net/s2io.c                      |    2 +-
 drivers/net/tg3.c                       |    6 +-
 drivers/net/vmxnet3/vmxnet3_ethtool.c   |    4 +-
 drivers/net/vxge/vxge-ethtool.c         |    4 +-
 include/linux/can/core.h                |    9 ++-
 include/linux/ethtool.h                 |    1 +
 include/linux/skbuff.h                  |    8 ++-
 include/net/dst.h                       |    2 +-
 include/net/rose.h                      |    8 ++-
 include/net/xfrm.h                      |   22 +++++++
 net/bridge/br_if.c                      |    6 ++-
 net/bridge/br_private.h                 |    2 +-
 net/bridge/br_stp_if.c                  |    9 ++-
 net/can/af_can.c                        |    9 +--
 net/can/bcm.c                           |    4 +-
 net/can/raw.c                           |    4 +-
 net/core/dev.c                          |   55 +----------------
 net/core/ethtool.c                      |   17 +++++-
 net/ipv4/fib_trie.c                     |    4 +-
 net/ipv4/ip_options.c                   |    6 +-
 net/ipv4/raw.c                          |    1 +
 net/ipv6/ip6mr.c                        |    2 +-
 net/irda/iriap.c                        |    6 ++
 net/irda/irnet/irnet_ppp.c              |    3 +
 net/rose/af_rose.c                      |    8 +-
 net/rose/rose_loopback.c                |   13 ++++-
 net/rose/rose_route.c                   |   20 ++++--
 net/rose/rose_subr.c                    |  101 +++++++++++++++++++++----------
 net/xfrm/xfrm_input.c                   |    4 +-
 net/xfrm/xfrm_output.c                  |    4 +-
 net/xfrm/xfrm_replay.c                  |   17 +++++-
 net/xfrm/xfrm_state.c                   |    6 ++
 net/xfrm/xfrm_user.c                    |   24 +++++++
 44 files changed, 329 insertions(+), 192 deletions(-)
