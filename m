From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/3] Netfilter updates for net-next
Date: Wed,  8 Jan 2014 20:13:21 +0100
Message-ID: <1389208404-3956-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54764 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751223AbaAHTNl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jan 2014 14:13:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The following patchset contains three Netfilter updates, they are:

* Fix wrong usage of skb_header_pointer in the DCCP protocol helper that
  has been there for quite some time. It was resulting in copying the dccp
  header to a pointer allocated in the stack. Fortunately, this pointer
  provides room for the dccp header is 4 bytes long, so no crashes have been
  reported so far. From Daniel Borkmann.

* Use format string to print in the invocation of nf_log_packet(), again
  in the DCCP helper. Also from Daniel Borkmann.

* Revert "netfilter: avoid get_random_bytes call" as prandom32 does not
  guarantee enough entropy when being calling this at boot time, that may
  happen when reloading the rule.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git master

Thanks!

P.S: I still have a pending pull request that should land anytime soon with
several nftables updates from Patrick, will send them asap to reach your merge
window.

----------------------------------------------------------------

The following changes since commit b912b2f8fc71df4c3ffa7a9fe2c2227e8bcdaa07:

  net/mlx4_core: Warn if device doesn't have enough PCI bandwidth (2014-01-05 20:37:05 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git master

for you to fetch changes up to b22f5126a24b3b2f15448c3f2a254fc10cbc2b92:

  netfilter: nf_conntrack_dccp: fix skb_header_pointer API usages (2014-01-06 17:40:02 +0100)

----------------------------------------------------------------
Daniel Borkmann (2):
      netfilter: nf_conntrack_dccp: use %s format string for buffer
      netfilter: nf_conntrack_dccp: fix skb_header_pointer API usages

Pablo Neira Ayuso (1):
      Revert "netfilter: avoid get_random_bytes calls"

 net/netfilter/nf_conntrack_proto_dccp.c |   10 +++++-----
 net/netfilter/nfnetlink_log.c           |    8 ++++++++
 net/netfilter/nft_hash.c                |    2 +-
 net/netfilter/xt_RATEEST.c              |    2 +-
 net/netfilter/xt_connlimit.c            |    2 +-
 net/netfilter/xt_hashlimit.c            |    2 +-
 net/netfilter/xt_recent.c               |    2 +-
 7 files changed, 18 insertions(+), 10 deletions(-)

-- 
1.7.10.4
