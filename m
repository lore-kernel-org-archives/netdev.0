From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/7] pull request: Netfilter/IPVS fixes for net
Date: Tue,  2 Sep 2014 12:13:57 +0200
Message-ID: <1409652844-10289-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

The following patchset contains seven Netfilter fixes for your net
tree, they are:

1) Make the NAT infrastructure independent of x_tables, some users are
   already starting to test nf_tables with NAT without enabling x_table=
s.
   Without this patch for Kconfig, there's a superfluous dependency
   between NAT and x_tables.
2) Allow to use 0 in the cgroup match, the kernel rejects with -EINVAL
   with no good reason. From Daniel Borkmann.

3) Select CONFIG_NF_NAT from the nf_tables NAT expression, this also
   resolves another NAT dependency with x_tables.

4) Use HAVE_JUMP_LABEL instead of CONFIG_JUMP_LABEL in the Netfilter ho=
ok
   code as elsewhere in the kernel to resolve toolchain problems, from
   Zhouyi Zhou.

5) Use iptunnel_handle_offloads() to set up tunnel encapsulation
   depending on the offload capabilities, reported by Alex Gartrell
   patch from Julian Anastasov.

6) Fix wrong family when registering the ip_vs_local_reply6() hook,
   also from Julian.

7) Select the NF_LOG_* symbols from NETFILTER_XT_TARGET_LOG. Rafa=C5=82
   Mi=C5=82ecki reported that when jumping from 3.16 to 3.17-rc, his lo=
g
   target is not selected anymore due to changes in the previous
   development cycle to accomodate the full logging support for
   nf_tables.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Thanks!

----------------------------------------------------------------

The following changes since commit 21009686662fd21412ca35def7cb3cc8346e=
1c3d:

  net: phy: smsc: move smsc_phy_config_init reset part in a soft_reset =
function (2014-08-16 20:15:54 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

for you to fetch changes up to d79a61d646db950b68dd79ecc627cb5f11e0d8ac=
:

  netfilter: NETFILTER_XT_TARGET_LOG selects NF_LOG_* (2014-09-01 13:46=
:31 +0200)

----------------------------------------------------------------
Daniel Borkmann (1):
      netfilter: x_tables: allow to use default cgroup match

Julian Anastasov (2):
      ipvs: properly declare tunnel encapsulation
      ipvs: fix ipv6 hook registration for local replies

Pablo Neira Ayuso (3):
      netfilter: move NAT Kconfig switches out of the iptables scope
      netfilter: nf_tables: nat expression must select CONFIG_NF_NAT
      netfilter: NETFILTER_XT_TARGET_LOG selects NF_LOG_*

Zhouyi Zhou (1):
      netfilter: HAVE_JUMP_LABEL instead of CONFIG_JUMP_LABEL

 include/linux/netfilter.h       |    5 +-
 net/ipv4/netfilter/Kconfig      |  102 +++++++++++++++++++++----------=
--------
 net/ipv4/netfilter/Makefile     |    2 +-
 net/ipv6/netfilter/Kconfig      |   26 +++++++---
 net/ipv6/netfilter/Makefile     |    2 +-
 net/netfilter/Kconfig           |    6 ++-
 net/netfilter/Makefile          |    2 +-
 net/netfilter/core.c            |    6 +--
 net/netfilter/ipvs/ip_vs_core.c |    2 +-
 net/netfilter/ipvs/ip_vs_xmit.c |   20 ++++++--
 net/netfilter/xt_cgroup.c       |    2 +-
 11 files changed, 105 insertions(+), 70 deletions(-)
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
