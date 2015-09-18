From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/4] Netfilter fixes for net
Date: Fri, 18 Sep 2015 11:17:52 +0200
Message-ID: <1442567876-4046-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

The following patch contains Netfilter fixes for your net tree, they are:

1) nf_log_unregister() should only set to NULL the logger that is being
   unregistered, instead of everything else. Patch from Florian Westphal.

2) Fix a crash when accessing physoutdev from PREROUTING in br_netfilter.
   This is partially reverting the patch to shrink nf_bridge_info to 32 bytes.
   Also from Florian.

3) Use existing match/target extensions in the internal nft_compat extension
   lists when the extension is family unspecific (ie. NFPROTO_UNSPEC).

4) Wait for rcu grace period before leaving nf_log_unregister().

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Thanks!

----------------------------------------------------------------

The following changes since commit e8684c88774c0ddfeefdbed0aa469b25b9962f3e:

  irda: ali-ircc: Fix deadlock in ali_ircc_sir_change_speed() (2015-09-11 16:18:33 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

for you to fetch changes up to ad5001cc7cdf9aaee5eb213fdee657e4a3c94776:

  netfilter: nf_log: wait for rcu grace after logger unregistration (2015-09-17 13:37:31 +0200)

----------------------------------------------------------------
Florian Westphal (2):
      netfilter: nf_log: don't zap all loggers on unregister
      netfilter: bridge: fix routing of bridge frames with call-iptables=1

Pablo Neira Ayuso (2):
      netfilter: nft_compat: skip family comparison in case of NFPROTO_UNSPEC
      netfilter: nf_log: wait for rcu grace after logger unregistration

 include/linux/skbuff.h     |    6 +++---
 net/netfilter/nf_log.c     |    9 +++++++--
 net/netfilter/nft_compat.c |   24 ++++++++++++++++++------
 3 files changed, 28 insertions(+), 11 deletions(-)
