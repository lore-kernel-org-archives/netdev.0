From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/8] Netfilter/IPVS fixes for net
Date: Sat, 28 Dec 2013 23:02:59 +0100
Message-ID: <1388268187-11569-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

This patchset contains four nf_tables fixes, one IPVS fix due to
missing updates in the interaction with the new sedadj conntrack
extension that was added to support the netfilter synproxy code,
and a couple of one-liners to fix netnamespace netfilter issues.
More specifically, they are:

* Fix ipv6_find_hdr() call without offset being explicitly initialized
  in nft_exthdr, as required by that function, from Daniel Borkmann.

* Fix oops in nfnetlink_log when using netns and unloading the kernel
  module, from Gao feng.

* Fix BUG_ON in nf_ct_timestamp extension after netns is destroyed,
  from Helmut Schaa.

* Fix crash in IPVS due to missing sequence adjustment extension being
  allocated in the conntrack, from Jesper Dangaard Brouer.

* Add bugtrap to spot a warning in case you deference sequence adjustment
  conntrack area when not available, this should help to catch similar
  invalid dereferences in the Netfilter tree, also from Jesper.

* Fix incomple dumping of sets in nf_tables when retrieving by family,
  from me.

* Fix oops when updating the table state (dormant <-> active) and having
  user (not base ) chains, from me.

* Fix wrong validation in set element data that results in returning
  -EINVAL when using the nf_tables dictionary feature with mappings,
  also from me.

We don't usually have this amount of fixes by this time (as we're already
in -rc5 of the development cycle), although half of them are related to
nf_tables which is a relatively new thing, and I also belive that holidays
have also delayed the flight of bugfixes to mainstream a bit.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

Thanks!

P.S: Have a nice entrance to new year.

----------------------------------------------------------------

The following changes since commit a7c12639bdf571a09578aed626875848d209d24f:

  Merge branch 'qlcnic' (2013-12-17 16:25:24 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

for you to fetch changes up to 2ee0d3c80fdb7974cfa1c7e25b5048e9fcaf69b6:

  netfilter: nf_tables: fix wrong datatype in nft_validate_data_load() (2013-12-28 22:32:28 +0100)

----------------------------------------------------------------
Daniel Borkmann (1):
      netfilter: nft_exthdr: call ipv6_find_hdr() with explicitly initialized offset

Gao feng (1):
      netfilter: nfnetlink_log: unset nf_loggers for netns when unloading module

Helmut Schaa (1):
      netfilter: nf_ct_timestamp: Fix BUG_ON after netns deletion

Jesper Dangaard Brouer (2):
      netfilter: WARN about wrong usage of sequence number adjustments
      ipvs: correct usage/allocation of seqadj ext in ipvs

Pablo Neira Ayuso (3):
      netfilter: nf_tables: fix dumping with large number of sets
      netfilter: nf_tables: fix oops when updating table with user chains
      netfilter: nf_tables: fix wrong datatype in nft_validate_data_load()

 net/netfilter/ipvs/ip_vs_nfct.c        |    6 ++++++
 net/netfilter/nf_conntrack_seqadj.c    |    5 +++++
 net/netfilter/nf_conntrack_timestamp.c |    1 -
 net/netfilter/nf_tables_api.c          |   26 ++++++++++++++++++++------
 net/netfilter/nfnetlink_log.c          |    1 +
 net/netfilter/nft_exthdr.c             |    2 +-
 6 files changed, 33 insertions(+), 8 deletions(-)
