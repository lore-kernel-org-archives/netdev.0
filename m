From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 00/11] Netfilter fixes for net
Date: Wed, 30 Nov 2016 22:57:14 +0100
Message-ID: <1480543045-3389-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

This is a large batch of Netfilter fixes for net, they are:

1) Three patches to fix NAT conversion to rhashtable: Switch to rhlist
   structure that allows to have several objects with the same key.
   Moreover, fix wrong comparison logic in nf_nat_bysource_cmp() as this is
   expecting a return value similar to memcmp(). Change location of
   the nat_bysource field in the nf_conn structure to avoid zeroing
   this as it breaks interaction with SLAB_DESTROY_BY_RCU and lead us
   to crashes. From Florian Westphal.

2) Don't allow malformed fragments go through in IPv6, drop them,
   otherwise we hit GPF, patch from Florian Westphal.

3) Fix crash if attributes are missing in nft_range, from Liping Zhang.

4) Fix arptables 32-bits userspace 64-bits kernel compat, from Hongxu Jia.

5) Two patches from David Ahern to fix netfilter interaction with vrf.
   From David Ahern.

6) Fix element timeout calculation in nf_tables, we take milliseconds
   from userspace, but we use jiffies from kernelspace. Patch from
   Anders K.  Pedersen.

7) Missing validation length netlink attribute for nft_hash, from
   Laura Garcia.

8) Fix nf_conntrack_helper documentation, we don't default to off
   anymore for a bit of time so let's get this in sync with the code.

I know is late but I think these are important, specifically the NAT
bits, as they are mostly addressing fallout from recent changes. I also
read there are chances to have -rc8, if that is the case, that would
also give us a bit more time to test this.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Thanks!

----------------------------------------------------------------

The following changes since commit b6e01232e25629907df9db19f25da7d4e8f5b589:

  net/mlx4_en: Free netdev resources under state lock (2016-11-23 20:18:36 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git HEAD

for you to fetch changes up to 17a49cd549d9dc8707dc9262210166455c612dde:

  netfilter: arp_tables: fix invoking 32bit "iptable -P INPUT ACCEPT" failed in 64bit kernel (2016-11-30 20:50:23 +0100)

----------------------------------------------------------------
Anders K. Pedersen (1):
      netfilter: nf_tables: fix inconsistent element expiration calculation

David Ahern (2):
      netfilter: Update ip_route_me_harder to consider L3 domain
      netfilter: Update nf_send_reset6 to consider L3 domain

Florian Westphal (5):
      netfilter: fix nf_conntrack_helper documentation
      netfilter: nat: fix cmp return value
      netfilter: nat: switch to new rhlist interface
      netfilter: nat: fix crash when conntrack entry is re-used
      netfilter: ipv6: nf_defrag: drop mangled skb on ream error

Hongxu Jia (1):
      netfilter: arp_tables: fix invoking 32bit "iptable -P INPUT ACCEPT" failed in 64bit kernel

Laura Garcia Liebana (1):
      netfilter: nft_hash: validate maximum value of u32 netlink hash attribute

Liping Zhang (1):
      netfilter: nft_range: add the missing NULL pointer check

 Documentation/networking/nf_conntrack-sysctl.txt |  7 +++-
 include/net/netfilter/nf_conntrack.h             |  6 +--
 include/net/netfilter/nf_tables.h                |  2 +-
 net/ipv4/netfilter.c                             |  5 ++-
 net/ipv4/netfilter/arp_tables.c                  |  4 +-
 net/ipv6/netfilter/nf_conntrack_reasm.c          |  4 +-
 net/ipv6/netfilter/nf_defrag_ipv6_hooks.c        |  2 +-
 net/ipv6/netfilter/nf_reject_ipv6.c              |  1 +
 net/netfilter/nf_nat_core.c                      | 49 +++++++++++++++---------
 net/netfilter/nf_tables_api.c                    | 14 ++++---
 net/netfilter/nft_hash.c                         |  7 +++-
 net/netfilter/nft_range.c                        |  6 +++
 12 files changed, 69 insertions(+), 38 deletions(-)
