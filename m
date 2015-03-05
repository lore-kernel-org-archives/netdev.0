From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/7] Netfilter/IPVS fixes for net
Date: Thu,  5 Mar 2015 21:48:42 +0100
Message-ID: <1425588529-4573-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

The following patchset contains Netfilter/IPVS fixes for your net tree,
they are:

1) Don't truncate ethernet protocol type to u8 in nft_compat, from
   Arturo Borrero.

2) Fix several problems in the addition/deletion of elements in nf_tables.

3) Fix module refcount leak in ip_vs_sync, from Julian Anastasov.

4) Fix a race condition in the abort path in the nf_tables transaction
   infrastructure. Basically aborted rules can show up as active rules
   until changes are unrolled, oneliner from Patrick McHardy.

5) Check for overflows in the data area of the rule, also from Patrick.

6) Fix off-by-one in the per-rule user data size field. This introduces
   a new nft_userdata structure that is placed at the beginning of the
   user data area that contains the length to save some bits from the
   rule and we only need one bit to indicate its presence, from Patrick.

7) Fix rule replacement error path, the replaced rule is deleted on
   error instead of leaving it in place. This has been fixed by relying
   on the abort path to undo the incomplete replacement.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Thanks a lot!

----------------------------------------------------------------

The following changes since commit 3f34b24a732bab9635c4b32823268c37c01b40f0:

  af_packet: allow packets defragmentation not only for hash fanout type (2015-02-21 23:00:18 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

for you to fetch changes up to 59900e0a019e7c2bdb7809a03ed5742d311b15b3:

  netfilter: nf_tables: fix error handling of rule replacement (2015-03-04 18:46:08 +0100)

----------------------------------------------------------------
Arturo Borrero (1):
      netfilter: nft_compat: don't truncate ethernet protocol type to u8

Julian Anastasov (1):
      ipvs: add missing ip_vs_pe_put in sync code

Pablo Neira Ayuso (3):
      netfilter: nf_tables: fix addition/deletion of elements from commit/abort
      Merge https://git.kernel.org/.../horms/ipvs
      netfilter: nf_tables: fix error handling of rule replacement

Patrick McHardy (3):
      netfilter: nf_tables: fix transaction race condition
      netfilter: nf_tables: check for overflow of rule dlen field
      netfilter: nf_tables: fix userdata length overflow

 include/net/netfilter/nf_tables.h |   22 +++++++++++--
 net/netfilter/ipvs/ip_vs_sync.c   |    3 ++
 net/netfilter/nf_tables_api.c     |   61 ++++++++++++++++++++++---------------
 net/netfilter/nft_compat.c        |   14 ++++-----
 4 files changed, 65 insertions(+), 35 deletions(-)
