From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 00/08: netfilter update
Date: Wed, 24 Feb 2010 18:49:27 +0100 (MET)
Message-ID: <20100224174927.16391.59798.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

following is the probably final netfilter update for 2.6.34, containing:

- an IPv6 reassembly fix for packets "fragmented" into a single fragment
  from myself

- an fix for an overflow and a false match in the recent match from Tim Gardner

- replacement of the xtables iteration macros by a set of new macros behaving
  more like the regular list iteration macros from Jan

Please apply or pull from:

git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-next-2.6.git master

Thanks!


 include/linux/netfilter/x_tables.h        |   17 ++
 include/linux/netfilter_arp/arp_tables.h  |   10 +-
 include/linux/netfilter_ipv4/ip_tables.h  |   15 +-
 include/linux/netfilter_ipv6/ip6_tables.h |   14 +-
 net/ipv4/netfilter/arp_tables.c           |  301 +++++++++-----------
 net/ipv4/netfilter/ip_tables.c            |  436 ++++++++++++++---------------
 net/ipv6/netfilter/ip6_tables.c           |  436 ++++++++++++++---------------
 net/ipv6/netfilter/nf_conntrack_reasm.c   |    8 +-
 net/netfilter/xt_TCPMSS.c                 |   12 +-
 net/netfilter/xt_recent.c                 |    4 +-
 10 files changed, 597 insertions(+), 656 deletions(-)

Jan Engelhardt (5):
      netfilter: xtables: replace XT_ENTRY_ITERATE macro
      netfilter: xtables: optimize call flow around xt_entry_foreach
      netfilter: xtables: replace XT_MATCH_ITERATE macro
      netfilter: xtables: optimize call flow around xt_ematch_foreach
      netfilter: xtables: reduce arguments to translate_table

Patrick McHardy (1):
      netfilter: nf_conntrack_reasm: properly handle packets fragmented into a single fragment

Tim Gardner (2):
      netfilter: xt_recent: fix buffer overflow
      netfilter: xt_recent: fix false match
