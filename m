From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Mon, 23 Mar 2015 13:00:45 -0400 (EDT)
Message-ID: <20150323.130045.419661360044429667.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


1) Validate iov ranges before feeding them into iov_iter_init(), from
   Al Viro.

2) We changed copy_from_msghdr_from_user() to zero out the msg_namelen is
   a NULL pointer is given for the msg_name.  Do the same in the compat
   code too.  From Catalin Marinas.

3) Fix partially initialized tuples in netfilter conntrack helper, from
   Ian Wilson.

4) Missing continue; statement in nft_hash walker can lead to crashes,
   from Herbert Xu.

5) tproxy_tg6_check looks for IP6T_INV_PROTO in ->flags instead
   of ->invflags, fix from Pablo Neira Ayuso.

6) Incorrect memory account of TCP FINs can result in negative socket
   memory accounting values.  Fix from Josh Hunt.

7) Don't allow virtual functions to enable VLAN promiscuous mode in
   be2net driver, from Vasundhara Volam.

Please pull, thanks a lot!

The following changes since commit b314acaccd7e0d55314d96be4a33b5f50d0b3344:

  Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/dtor/input (2015-03-19 16:43:10 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master

for you to fetch changes up to c0e41fa76c5f3775c9479f6babcb94d54da08a51:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf (2015-03-22 16:57:07 -0400)

----------------------------------------------------------------

Al Viro (1):
      net: validate the range we feed to iov_iter_init() in sys_sendto/sys_recvfrom

Catalin Marinas (1):
      net: compat: Update get_compat_msghdr() to match copy_msghdr_from_user() behaviour

David S. Miller (2):
      Merge branch 'be2net'
      Merge git://git.kernel.org/.../pablo/nf

Herbert Xu (1):
      netfilter: Fix potential crash in nft_hash walker

Ian Wilson (1):
      netfilter: Zero the tuple in nfnl_cthelper_parse_tuple()

Josh Hunt (1):
      tcp: fix tcp fin memory accounting

Markos Chandras (1):
      net: ethernet: pcnet32: Setup the SRAM and NOUFLO on Am79C97{3, 5}

Ondrej Zary (1):
      cx82310_eth: wait for firmware to become ready

Pablo Neira Ayuso (4):
      netfilter: nf_tables: allow to change chain policy without hook if it exists
      netfilter: restore rule tracing via nfnetlink_log
      netfilter: xt_TPROXY: fix invflags check in tproxy_tg6_check()
      netfilter: nft_compat: set IP6T_F_PROTO flag if protocol is set

Sabrina Dubroca (1):
      ipv6: call ipv6_proxy_select_ident instead of ipv6_select_ident in udp6_ufo_fragment

Steven Barth (1):
      ipv6: fix backtracking for throw routes

Suresh Reddy (2):
      be2net: restrict MODIFY_EQ_DELAY cmd to a max of 8 EQs
      be2net: use PCI MMIO read instead of config read for errors

Vasundhara Volam (1):
      be2net: Prevent VFs from enabling VLAN promiscuous mode

 drivers/net/ethernet/amd/pcnet32.c          |  31 +++++++++++++++++++++--
 drivers/net/ethernet/emulex/benet/be.h      |   2 ++
 drivers/net/ethernet/emulex/benet/be_cmds.c |  17 +++++--------
 drivers/net/ethernet/emulex/benet/be_cmds.h |   2 +-
 drivers/net/ethernet/emulex/benet/be_main.c | 131 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++------------------------
 drivers/net/usb/cx82310_eth.c               |  30 +++++++++++++++++-----
 include/net/netfilter/nf_log.h              |  10 ++++++++
 net/compat.c                                |   7 +++++
 net/ipv4/netfilter/ip_tables.c              |   6 ++---
 net/ipv4/tcp_output.c                       |   6 +----
 net/ipv6/fib6_rules.c                       |   1 +
 net/ipv6/netfilter/ip6_tables.c             |   6 ++---
 net/ipv6/udp_offload.c                      |   8 +++---
 net/netfilter/nf_log.c                      |  24 ++++++++++++++++++
 net/netfilter/nf_tables_api.c               |   5 +++-
 net/netfilter/nf_tables_core.c              |   8 +++---
 net/netfilter/nfnetlink_cthelper.c          |   3 +++
 net/netfilter/nft_compat.c                  |   6 +++++
 net/netfilter/nft_hash.c                    |   2 ++
 net/netfilter/xt_TPROXY.c                   |   4 +--
 net/socket.c                                |   4 +++
 21 files changed, 238 insertions(+), 75 deletions(-)
