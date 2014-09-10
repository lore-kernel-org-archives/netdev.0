From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 00/25] nf-next pull request
Date: Wed, 10 Sep 2014 17:10:17 +0200
Message-ID: <1410361842-4656-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

The following patchset contains Netfilter/IPVS updates for your
net-next tree. Regarding nf_tables, most updates focus on consolidating
the NAT infrastructure and adding support for masquerading. More
specifically, they are:

1) use __u8 instead of u_int8_t in arptables header, from
   Mike Frysinger.

2) Add support to match by skb->pkttype to the meta expression, from
   Ana Rey.

3) Add support to match by cpu to the meta expression, also from
   Ana Rey.

4) A smatch warning about IPSET_ATTR_MARKMASK validation, patch from
   Vytas Dauksa.

5) Fix netnet and netportnet hash types the range support for IPv4,
   from Sergey Popovich.

6) Fix missing-field-initializer warnings resolved, from Mark Rustad.

7) Dan Carperter reported possible integer overflows in ipset, from
   Jozsef Kadlecsick.

8) Filter out accounting objects in nfacct by type, so you can
   selectively reset quotas, from Alexey Perevalov.

9) Move specific NAT IPv4 functions to the core so x_tables and
   nf_tables can share the same NAT IPv4 engine.

10) Use the new NAT IPv4 functions from nft_chain_nat_ipv4.

11) Move specific NAT IPv6 functions to the core so x_tables and
    nf_tables can share the same NAT IPv4 engine.

12) Use the new NAT IPv6 functions from nft_chain_nat_ipv6.

13) Refactor code to add nft_delrule(), which can be reused in the
    enhancement of the NFT_MSG_DELTABLE to remove a table and its
    content, from Arturo Borrero.

14) Add a helper function to unregister chain hooks, from
    Arturo Borrero.

15) A cleanup to rename to nft_delrule_by_chain for consistency with
    the new nft_*() functions, also from Arturo.

16) Add support to match devgroup to the meta expression, from Ana Rey.

17) Reduce stack usage for IPVS socket option, from Julian Anastasov.

18) Remove unnecessary textsearch state initialization in xt_string,
    from Bojan Prtvar.

19) Add several helper functions to nf_tables, more work to prepare
    the enhancement of NFT_MSG_DELTABLE, again from Arturo Borrero.

20) Enhance NFT_MSG_DELTABLE to delete a table and its content, from
    Arturo Borrero.

21) Support NAT flags in the nat expression to indicate the flavour,
    eg. random fully, from Arturo.

22) Add missing audit code to ebtables when replacing tables, from
    Nicolas Dichtel.

23) Generalize the IPv4 masquerading code to allow its re-use from
    nf_tables, from Arturo.

24) Generalize the IPv6 masquerading code, also from Arturo.

25) Add the new masq expression to support IPv4/IPv6 masquerading
    from nf_tables, also from Arturo.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git

Thanks!

----------------------------------------------------------------

The following changes since commit c9d26423e56ce1ab4d786f92aebecf859d419293:

  Merge tag 'pm+acpi-3.17-rc1-2' of git://git.kernel.org/pub/scm/linux/kernel/git/rafael/linux-pm (2014-08-14 18:13:46 -0600)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git master

for you to fetch changes up to 9ba1f726bec090399eb9bb9157eb32dedc8e8c45:

  netfilter: nf_tables: add new nft_masq expression (2014-09-09 16:31:30 +0200)

----------------------------------------------------------------
Alexey Perevalov (1):
      netfilter: nfnetlink_acct: add filter support to nfacct counter list/reset

Ana Rey (3):
      netfilter: nft_meta: add pkttype support
      netfilter: nft_meta: Add cpu attribute support
      netfilter: nf_tables: add devgroup support in meta expresion

Arturo Borrero (9):
      netfilter: nf_tables: refactor rule deletion helper
      netfilter: nf_tables: add helper to unregister chain hooks
      netfilter: nf_tables: rename nf_table_delrule_by_chain()
      netfilter: nf_tables: add helpers to schedule objects deletion
      netfilter: nf_tables: extend NFT_MSG_DELTABLE to support flushing the ruleset
      netfilter: nft_nat: include a flag attribute
      netfilter: nf_nat: generalize IPv4 masquerading support for nf_tables
      netfilter: nf_nat: generalize IPv6 masquerading support for nf_tables
      netfilter: nf_tables: add new nft_masq expression

Bojan Prtvar (1):
      netfilter: xt_string: Remove unnecessary initialization of struct ts_state

Jozsef Kadlecsik (1):
      netfilter: ipset: Fix warn: integer overflows 'sizeof(*map) + size * set->dsize'

Julian Anastasov (1):
      ipvs: reduce stack usage for sockopt data

Mark Rustad (1):
      netfilter: ipset: Resolve missing-field-initializer warnings

Mike Frysinger (1):
      uapi: netfilter_arp: use __u8 instead of u_int8_t

Nicolas Dichtel (1):
      netfilter: ebtables: create audit records for replaces

Pablo Neira Ayuso (4):
      netfilter: nat: move specific NAT IPv4 to core
      netfilter: nft_chain_nat_ipv4: use generic IPv4 NAT code from core
      netfilter: nat: move specific NAT IPv6 to core
      netfilter: nft_chain_nat_ipv6: use generic IPv6 NAT code from core

Sergey Popovich (1):
      netfilter: ipset: netnet,netportnet: Fix value range support for IPv4

Vytas Dauksa (1):
      netfilter: ipset: Removed invalid IPSET_ATTR_MARKMASK validation

 include/linux/netfilter/ipset/ip_set_list.h    |    1 +
 include/net/netfilter/ipv4/nf_nat_masquerade.h |   14 +
 include/net/netfilter/ipv6/nf_nat_masquerade.h |   10 +
 include/net/netfilter/nf_nat_l3proto.h         |   75 ++++
 include/net/netfilter/nft_masq.h               |   16 +
 include/uapi/linux/netfilter/nf_nat.h          |    5 +
 include/uapi/linux/netfilter/nf_tables.h       |   21 ++
 include/uapi/linux/netfilter/nfnetlink_acct.h  |    8 +
 include/uapi/linux/netfilter_arp/arpt_mangle.h |    2 +-
 net/bridge/netfilter/ebtables.c                |   15 +
 net/ipv4/netfilter/Kconfig                     |   13 +
 net/ipv4/netfilter/Makefile                    |    2 +
 net/ipv4/netfilter/ipt_MASQUERADE.c            |  108 +-----
 net/ipv4/netfilter/iptable_nat.c               |  233 ++----------
 net/ipv4/netfilter/nf_nat_l3proto_ipv4.c       |  199 +++++++++++
 net/ipv4/netfilter/nf_nat_masquerade_ipv4.c    |  153 ++++++++
 net/ipv4/netfilter/nft_chain_nat_ipv4.c        |  157 ++------
 net/ipv4/netfilter/nft_masq_ipv4.c             |   89 +++++
 net/ipv6/netfilter/Kconfig                     |   13 +
 net/ipv6/netfilter/Makefile                    |    2 +
 net/ipv6/netfilter/ip6t_MASQUERADE.c           |   76 +---
 net/ipv6/netfilter/ip6table_nat.c              |  233 ++----------
 net/ipv6/netfilter/nf_nat_l3proto_ipv6.c       |  199 +++++++++++
 net/ipv6/netfilter/nf_nat_masquerade_ipv6.c    |  120 +++++++
 net/ipv6/netfilter/nft_chain_nat_ipv6.c        |  165 ++-------
 net/ipv6/netfilter/nft_masq_ipv6.c             |   89 +++++
 net/netfilter/Kconfig                          |    9 +
 net/netfilter/Makefile                         |    1 +
 net/netfilter/ipset/ip_set_bitmap_ip.c         |    4 +-
 net/netfilter/ipset/ip_set_bitmap_ipmac.c      |    4 +-
 net/netfilter/ipset/ip_set_bitmap_port.c       |    4 +-
 net/netfilter/ipset/ip_set_hash_gen.h          |    2 +-
 net/netfilter/ipset/ip_set_hash_ip.c           |    8 +-
 net/netfilter/ipset/ip_set_hash_ipport.c       |    8 +-
 net/netfilter/ipset/ip_set_hash_ipportip.c     |    8 +-
 net/netfilter/ipset/ip_set_hash_netnet.c       |   13 +-
 net/netfilter/ipset/ip_set_hash_netportnet.c   |    6 +-
 net/netfilter/ipset/ip_set_list_set.c          |    4 +-
 net/netfilter/ipvs/ip_vs_ctl.c                 |  111 +++---
 net/netfilter/nf_tables_api.c                  |  454 +++++++++++++++---------
 net/netfilter/nfnetlink_acct.c                 |   54 +++
 net/netfilter/nft_masq.c                       |   59 +++
 net/netfilter/nft_meta.c                       |   45 +++
 net/netfilter/nft_nat.c                        |   16 +
 net/netfilter/xt_string.c                      |    1 -
 45 files changed, 1759 insertions(+), 1070 deletions(-)
 create mode 100644 include/net/netfilter/ipv4/nf_nat_masquerade.h
 create mode 100644 include/net/netfilter/ipv6/nf_nat_masquerade.h
 create mode 100644 include/net/netfilter/nft_masq.h
 create mode 100644 net/ipv4/netfilter/nf_nat_masquerade_ipv4.c
 create mode 100644 net/ipv4/netfilter/nft_masq_ipv4.c
 create mode 100644 net/ipv6/netfilter/nf_nat_masquerade_ipv6.c
 create mode 100644 net/ipv6/netfilter/nft_masq_ipv6.c
 create mode 100644 net/netfilter/nft_masq.c
