From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Fri, 05 Nov 2010 15:14:39 -0700 (PDT)
Message-ID: <20101105.151439.71090650.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37128
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752728Ab0KEWOP convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Nov 2010 18:14:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Here are the bug fixes that have queued up since -rc1,
several "touches netdev queue before device registry"
cases as well as the "net dst" percpu fixup you want
to see merged ASAP.

Please pull, thanks a lot!

The following changes since commit ff8b16d7e15a8ba2a6086645614a483e048e=
3fbf:

  vmstat: fix offset calculation on void* (2010-11-03 14:39:58 -0400)

are available in the git repository at:
  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Amerigo Wang (1):
      netxen: remove unused firmware exports

Andr=E9 Carvalho de Matos (1):
      caif: Bugfix for socket priority, bindtodev and dbg channel.

David S. Miller (2):
      ibm_newemac: Remove netif_stop_queue() in emac_probe().
      Merge branch 'master' of git://git.kernel.org/.../kaber/nf-2.6

Divy Le Ray (3):
      cxgb3: remove call to stop TX queues at load time.
      cxgb4: remove call to stop TX queues at load time.
      cxgb4vf: remove call to stop TX queues at load time.

Dmitry Artamonow (1):
      USB: gadget: fix ethernet gadget crash in gether_setup

Dr. David Alan Gilbert (1):
      l2tp: kzalloc with swapped params in l2tp_dfs_seq_open

Eric Dumazet (7):
      netfilter: nf_conntrack: allow nf_ct_alloc_hashtable() to get hig=
hmem pages
      netfilter: fix nf_conntrack_l4proto_register()
      jme: fix panic on load
      qlcnic: fix panic on load
      atl1 : fix panic on load
      de2104x: fix panic on load
      fib: fib_result_assign() should not change fib refcounts

Herbert Xu (1):
      cls_cgroup: Fix crash on module unload

Jan Engelhardt (1):
      netfilter: ip6_tables: fix information leak to userspace

John Faith (1):
      smsc911x: Set Ethernet EEPROM size to supported device's size

Ming Lei (1):
      usbnet: fix usb_autopm_get_interface failure(v1)

Nelson Elhage (2):
      netlink: Make nlmsg_find_attr take a const nlmsghdr*.
      inet_diag: Make sure we actually run the same bytecode we audited=
=2E

Patrick McHardy (1):
      netfilter: nf_nat: fix compiler warning with CONFIG_NF_CT_NETLINK=
=3Dn

Pavel Emelyanov (2):
      rds: Lost locking in loop connection freeing
      rds: Remove kfreed tcp conn from list

Sjur Br=E6ndeland (1):
      caif: SPI-driver bugfix - incorrect padding.

Thomas Graf (1):
      text ematch: check for NULL pointer before destroying textsearch =
config

Tom Herbert (1):
      net: check queue_index from sock is valid for device

Uwe Kleine-K=F6nig (1):
      trivial: fix typos concerning "function"

Vasiliy Kulikov (2):
      ipv4: netfilter: arp_tables: fix information leak to userland
      ipv4: netfilter: ip_tables: fix information leak to userland

Xiaotian Feng (1):
      net dst: fix percpu_counter list corruption and poison overwritte=
n

Yaniv Rosner (8):
      bnx2x: Restore appropriate delay during BMAC reset
      bnx2x: Fix waiting for reset complete on BCM848x3 PHYs
      bnx2x: Fix port selection in case of E2
      bnx2x: Clear latch indication on link reset
      bnx2x: Fix resetting BCM8726 PHY during common init
      bnx2x: Do not enable CL37 BAM unless it is explicitly enabled
      bnx2x: Reset 8073 phy during common init
      bnx2x: Update version number

andrew hendry (1):
      memory corruption in X.25 facilities parsing

sjur.brandeland@stericsson.com (1):
      caif: Remove noisy printout when disconnecting caif socket

 drivers/isdn/hisax/isar.c            |    4 +-
 drivers/net/atlx/atl1.c              |    1 -
 drivers/net/bnx2x/bnx2x.h            |    4 +-
 drivers/net/bnx2x/bnx2x_hsi.h        |    9 +++++-
 drivers/net/bnx2x/bnx2x_link.c       |   57 +++++++++++++++++++++++++-=
--------
 drivers/net/caif/caif_spi.c          |   57 +++++++++++++++++++++++++-=
--------
 drivers/net/caif/caif_spi_slave.c    |   13 +++++--
 drivers/net/cxgb3/cxgb3_main.c       |    1 -
 drivers/net/cxgb4/cxgb4_main.c       |    1 -
 drivers/net/cxgb4vf/cxgb4vf_main.c   |    1 -
 drivers/net/ibm_newemac/core.c       |    1 -
 drivers/net/jme.c                    |    4 --
 drivers/net/netxen/netxen_nic_main.c |    3 --
 drivers/net/qlcnic/qlcnic_main.c     |    1 -
 drivers/net/smsc911x.h               |    2 +-
 drivers/net/tulip/de2104x.c          |    1 -
 drivers/net/usb/usbnet.c             |   11 ++++++
 drivers/usb/gadget/u_ether.c         |    1 -
 include/net/caif/caif_dev.h          |    4 +-
 include/net/caif/caif_spi.h          |    2 +
 include/net/caif/cfcnfg.h            |    8 ++--
 include/net/netlink.h                |    2 +-
 net/caif/caif_config_util.c          |   13 ++++++--
 net/caif/caif_dev.c                  |    2 +
 net/caif/caif_socket.c               |   45 +++++++++-----------------=
-
 net/caif/cfcnfg.c                    |   17 ++++------
 net/caif/cfctrl.c                    |    3 +-
 net/caif/cfdbgl.c                    |   14 ++++++++
 net/caif/cfrfml.c                    |    2 +-
 net/core/dev.c                       |    2 +-
 net/ipv4/fib_lookup.h                |    5 +--
 net/ipv4/inet_diag.c                 |   27 +++++++++------
 net/ipv4/netfilter/arp_tables.c      |    1 +
 net/ipv4/netfilter/ip_tables.c       |    1 +
 net/ipv4/netfilter/nf_nat_core.c     |   40 ++++++++++++------------
 net/ipv6/netfilter/ip6_tables.c      |    1 +
 net/ipv6/route.c                     |    2 +
 net/l2tp/l2tp_debugfs.c              |    2 +-
 net/netfilter/nf_conntrack_core.c    |    3 +-
 net/netfilter/nf_conntrack_proto.c   |    6 +++
 net/rds/loop.c                       |    4 ++
 net/rds/tcp.c                        |    6 +++
 net/sched/cls_cgroup.c               |    2 -
 net/sched/em_text.c                  |    3 +-
 net/x25/x25_facilities.c             |    8 ++--
 net/x25/x25_in.c                     |    2 +
 46 files changed, 246 insertions(+), 153 deletions(-)
