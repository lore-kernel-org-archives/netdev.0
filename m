From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/9] Netfilter fixes for net
Date: Wed, 10 Aug 2016 21:16:36 +0200
Message-ID: <1470856605-7903-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Resending as my robot didn't Cc netdev, sorry.

-o-

Hi David,

The following patchset contains Netfilter fixes for your net tree,
they are:

1) Use mod_timer_pending() to avoid reactivating a dead expectation in
   the h323 conntrack helper, from Liping Zhang.

2) Oneliner to fix a type in the register name defined in the nf_tables
   header.

3) Don't try to look further when we find an inactive elements with no
   descendants in the rbtree set implementation, otherwise we crash.

4) Handle valid zero CSeq in the SIP conntrack helper, from
   Christophe Leroy.

5) Don't display a trailing slash in conntrack helper with no classes
   via /proc/net/nf_conntrack_expect, from Liping Zhang.

6) Fix an expectation leak during creation from the nfqueue path, again
   from Liping Zhang.

7) Validate netlink port ID in verdict message from nfqueue, otherwise
   an injection can be possible. Again from Zhang.

8) Reject conntrack tuples with different transport protocol on
   original and reply tuples, also from Zhang.

9) Validate offset and length in nft_exthdr, make sure they are under
   sizeof(u8), from Laura Garcia Liebana.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Thanks!

----------------------------------------------------------------

The following changes since commit c518189567eaf42b2ec50a4d982484c8e38799f8:

  net: macb: Correct CAPS mask (2016-08-06 20:53:06 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git HEAD

for you to fetch changes up to 4da449ae1df9cfeb167e78f250b250eff64bc65e:

  netfilter: nft_exthdr: Add size check on u8 nft_exthdr attributes (2016-08-10 13:10:13 +0200)

----------------------------------------------------------------
Christophe Leroy (1):
      netfilter: nf_conntrack_sip: CSeq 0 is a valid CSeq

Laura Garcia Liebana (1):
      netfilter: nft_exthdr: Add size check on u8 nft_exthdr attributes

Liping Zhang (5):
      netfilter: nf_ct_h323: do not re-activate already expired timer
      netfilter: nf_ct_expect: remove the redundant slash when policy name is empty
      netfilter: nfnetlink_queue: fix memory leak when attach expectation successfully
      netfilter: nfnetlink_queue: reject verdict request from different portid
      netfilter: ctnetlink: reject new conntrack request with different l4proto

Pablo Neira Ayuso (2):
      netfilter: nf_tables: s/MFT_REG32_01/NFT_REG32_01
      netfilter: nft_rbtree: ignore inactive matching element with no descendants

 include/uapi/linux/netfilter/nf_tables.h |  2 +-
 net/netfilter/nf_conntrack_expect.c      |  2 +-
 net/netfilter/nf_conntrack_h323_main.c   |  3 ++-
 net/netfilter/nf_conntrack_netlink.c     | 10 ++++------
 net/netfilter/nf_conntrack_sip.c         |  4 ++--
 net/netfilter/nfnetlink_queue.c          |  6 ++----
 net/netfilter/nft_exthdr.c               | 11 +++++++++--
 net/netfilter/nft_rbtree.c               | 10 ++++++----
 8 files changed, 27 insertions(+), 21 deletions(-)
