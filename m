From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/6] Netfilter fixes for net
Date: Thu,  3 Sep 2015 11:50:55 +0200
Message-ID: <1441273861-31092-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:46730 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751685AbbICJoh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Sep 2015 05:44:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The following patchset contains Netfilter fixes for net, they are:

1) Oneliner to restore maps in nf_tables since we support addressing registers
   at 32 bits level.

2) Restore previous default behaviour in bridge netfilter when CONFIG_IPV6=n,
   oneliner from Bernhard Thaler.

3) Out of bound access in ipset hash:net* set types, reported by Dave Jones'
   KASan utility, patch from Jozsef Kadlecsik.

4) Fix ipset compilation with gcc 4.4.7 related to C99 initialization of
   unnamed unions, patch from Elad Raz.

5) Add a workaround to address inconsistent endianess in the res_id field of
   nfnetlink batch messages, reported by Florian Westphal.

6) Fix error paths of CT/synproxy since the conntrack template was moved to use
   kmalloc, patch from Daniel Borkmann.

All of them look good to me to reach 4.2, I can route this to -stable myself
too, just let me know what you prefer.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Thanks!

----------------------------------------------------------------

The following changes since commit fd7dec25a18f495e50d2040398fd263836ff3b28:

  batman-adv: Fix memory leak on tt add with invalid vlan (2015-08-18 19:08:23 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

for you to fetch changes up to 9cf94eab8b309e8bcc78b41dd1561c75b537dd0b:

  netfilter: conntrack: use nf_ct_tmpl_free in CT/synproxy error paths (2015-09-01 12:15:08 +0200)

----------------------------------------------------------------
Bernhard Thaler (1):
      netfilter: bridge: fix IPv6 packets not being bridged with CONFIG_IPV6=n

Daniel Borkmann (1):
      netfilter: conntrack: use nf_ct_tmpl_free in CT/synproxy error paths

Elad Raz (1):
      netfilter: ipset: Fixing unnamed union init

Jozsef Kadlecsik (1):
      netfilter: ipset: Out of bound access in hash:net* types fixed

Pablo Neira Ayuso (2):
      netfilter: nf_tables: Use 32 bit addressing register from nft_type_to_reg()
      netfilter: nfnetlink: work around wrong endianess in res_id field

 include/net/netfilter/br_netfilter.h         |    2 +-
 include/net/netfilter/nf_conntrack.h         |    1 +
 include/net/netfilter/nf_tables.h            |    2 +-
 net/netfilter/ipset/ip_set_hash_gen.h        |   12 ++++++++----
 net/netfilter/ipset/ip_set_hash_netnet.c     |   20 ++++++++++++++++++--
 net/netfilter/ipset/ip_set_hash_netportnet.c |   20 ++++++++++++++++++--
 net/netfilter/nf_conntrack_core.c            |    3 ++-
 net/netfilter/nf_synproxy_core.c             |    2 +-
 net/netfilter/nfnetlink.c                    |    8 +++++++-
 net/netfilter/xt_CT.c                        |    2 +-
 10 files changed, 58 insertions(+), 14 deletions(-)
