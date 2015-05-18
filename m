From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 00/21] Netfilter updates for net-next
Date: Mon, 18 May 2015 18:25:03 +0200
Message-ID: <1431966324-4494-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

The following patchset contains Netfilter updates for net-next. Briefly
speaking, cleanups and minor fixes for ipset from Jozsef Kadlecsik and
Serget Popovich, more incremental updates to make br_netfilter a better
place from Florian Westphal, ARP support to the x_tables mark match /
target from and context Zhang Chunyu and the addition of context to know
that the x_tables runs through nft_compat. More specifically, they are:

1) Fix sparse warning in ipset/ip_set_hash_ipmark.c when fetching the
   IPSET_ATTR_MARK netlink attribute, from Jozsef Kadlecsik.

2) Rename STREQ macro to STRNCMP in ipset, also from Jozsef.

3) Use skb->network_header to calculate the transport offset in
   ip_set_get_ip{4,6}_port(). From Alexander Drozdov.

4) Reduce memory consumption per element due to size miscalculation,
   this patch and follow up patches from Sergey Popovich.

5) Expand nomatch field from 1 bit to 8 bits to allow to simplify
   mtype_data_reset_flags(), also from Sergey.

6) Small clean for ipset macro trickery.

7) Fix error reporting when both ip_set_get_hostipaddr4() and
   ip_set_get_extensions() from per-set uadt functions.

8) Simplify IPSET_ATTR_PORT netlink attribute validation.

9) Introduce HOST_MASK instead of hardcoded 32 in ipset.

10) Return true/false instead of 0/1 in functions that return boolean
    in the ipset code.

11) Validate maximum length of the IPSET_ATTR_COMMENT netlink attribute.

12) Allow to dereference from ext_*() ipset macros.

13) Get rid of incorrect definitions of HKEY_DATALEN.

14) Include linux/netfilter/ipset/ip_set.h in the x_tables set match.

15) Reduce nf_bridge_info size in br_netfilter, from Florian Westphal.

16) Release nf_bridge_info after POSTROUTING since this is only needed
    from the physdev match, also from Florian.

17) Reduce size of ipset code by deinlining ip_set_put_extensions(),
    from Denys Vlasenko.

18) Oneliner to add ARP support to the x_tables mark match/target, from
    Zhang Chunyu.

19) Add context to know if the x_tables extension runs from nft_compat,
    to address minor problems with three existing extensions.

20) Correct return value in several seqfile *_show() functions in the
    netfilter tree, from Joe Perches.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git

Thanks!

----------------------------------------------------------------

The following changes since commit 9449c3cd90472141cf081af88181a56163ff7132:

  net: make skb_dst_pop routine static (2015-05-12 23:19:49 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git master

for you to fetch changes up to 861fb1078fd4ea09b442987b3e20fced0f15eb92:

  netfilter: Use correct return for seq_show functions (2015-05-17 17:25:35 +0200)

----------------------------------------------------------------
Alexander Drozdov (1):
      netfilter: ipset: make ip_set_get_ip*_port to use skb_network_offset

Denys Vlasenko (1):
      netfilter: ipset: deinline ip_set_put_extensions()

Florian Westphal (2):
      netfilter: bridge: neigh_head and physoutdev can't be used at same time
      netfilter: bridge: free nf_bridge info on xmit

Joe Perches (1):
      netfilter: Use correct return for seq_show functions

Jozsef Kadlecsik (3):
      netfilter: ipset: Fix sparse warning
      netfilter: ipset: Give a better name to a macro in ip_set_core.c
      netfilter: ipset: Use better include files in xt_set.c

Pablo Neira Ayuso (1):
      netfilter: x_tables: add context to know if extension runs from nft_compat

Sergey Popovich (11):
      netfilter: ipset: Properly calculate extensions offsets and total length
      netfilter: ipset: No need to make nomatch bitfield
      netfilter: ipset: Preprocessor directices cleanup
      netfilter: ipset: Return ipset error instead of bool
      netfilter: ipset: Check IPSET_ATTR_PORT only once
      netfilter: ipset: Use HOST_MASK literal to represent host address CIDR len
      netfilter: ipset: Return bool values instead of int
      netfilter: ipset: Check for comment netlink attribute length
      netfilter: ipset: Fix ext_*() macros
      netfilter: ipset: Fix hashing for ipv6 sets
      netfilter: ipset: Improve preprocessor macros checks

Zhang Chunyu (1):
      netfilter: xt_MARK: Add ARP support

 include/linux/netfilter/ipset/ip_set.h       |   32 +++-------------
 include/linux/netfilter/x_tables.h           |    2 +
 include/linux/skbuff.h                       |    8 ++--
 net/bridge/br_netfilter.c                    |   19 +++++++++-
 net/bridge/netfilter/ebt_stp.c               |    6 ++-
 net/ipv4/netfilter/ipt_CLUSTERIP.c           |    5 +++
 net/netfilter/ipset/ip_set_bitmap_ip.c       |   17 ++++++---
 net/netfilter/ipset/ip_set_bitmap_ipmac.c    |   13 +++++--
 net/netfilter/ipset/ip_set_bitmap_port.c     |    3 +-
 net/netfilter/ipset/ip_set_core.c            |   49 ++++++++++++++++++------
 net/netfilter/ipset/ip_set_getport.c         |    6 ++-
 net/netfilter/ipset/ip_set_hash_gen.h        |   22 +++++++++--
 net/netfilter/ipset/ip_set_hash_ip.c         |   33 ++++++++--------
 net/netfilter/ipset/ip_set_hash_ipmark.c     |   43 ++++++++++-----------
 net/netfilter/ipset/ip_set_hash_ipport.c     |   49 +++++++++++-------------
 net/netfilter/ipset/ip_set_hash_ipportip.c   |   40 ++++++++++----------
 net/netfilter/ipset/ip_set_hash_ipportnet.c  |   40 ++++++++++----------
 net/netfilter/ipset/ip_set_hash_mac.c        |   11 ++++--
 net/netfilter/ipset/ip_set_hash_net.c        |   28 ++++++++------
 net/netfilter/ipset/ip_set_hash_netiface.c   |   29 +++++++-------
 net/netfilter/ipset/ip_set_hash_netnet.c     |   30 ++++++++++-----
 net/netfilter/ipset/ip_set_hash_netport.c    |   38 +++++++++----------
 net/netfilter/ipset/ip_set_hash_netportnet.c |   52 ++++++++++++++------------
 net/netfilter/ipset/ip_set_list_set.c        |    3 +-
 net/netfilter/nfnetlink_queue_core.c         |    2 +-
 net/netfilter/nft_compat.c                   |    2 +
 net/netfilter/x_tables.c                     |   18 +++------
 net/netfilter/xt_TCPMSS.c                    |    6 +++
 net/netfilter/xt_mark.c                      |    1 +
 net/netfilter/xt_set.c                       |    3 +-
 30 files changed, 346 insertions(+), 264 deletions(-)
