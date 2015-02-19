From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/4] Netfilter/IPVS fixes for net
Date: Thu, 19 Feb 2015 19:19:16 +0100
Message-ID: <1424369960-10988-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:58527 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752092AbbBSSQM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Feb 2015 13:16:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The following patchset contains updates for your net tree, they are:

1) Fix removal of destination in IPVS when the new mixed family support
   is used, from Alexey Andriyanov via Simon Horman.

2) Fix module refcount undeflow in nft_compat when reusing a match /
   target.

3) Fix iptables-restore when the recent match is used with a new hitcount
   that exceeds threshold, from Florian Westphal.

4) Fix stack corruption in xt_socket due to using stack storage to save
   the inner IPv6 header, from Eric Dumazet.

I'll follow up soon with another batch with more fixes that are still
cooking.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Thanks!

----------------------------------------------------------------

The following changes since commit 42b5212fee4f57907e9415b18fe19c13e65574bc:

  xen-netback: stop the guest rx thread after a fatal error (2015-02-02 19:39:04 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

for you to fetch changes up to 78296c97ca1fd3b104f12e1f1fbc06c46635990b:

  netfilter: xt_socket: fix a stack corruption bug (2015-02-16 17:00:48 +0100)

----------------------------------------------------------------
Alexey Andriyanov (1):
      ipvs: fix inability to remove a mixed-family RS

Eric Dumazet (1):
      netfilter: xt_socket: fix a stack corruption bug

Florian Westphal (1):
      netfilter: xt_recent: don't reject rule if new hitcount exceeds table max

Pablo Neira Ayuso (1):
      netfilter: nft_compat: fix module refcount underflow

 net/netfilter/ipvs/ip_vs_ctl.c |    2 +-
 net/netfilter/nft_compat.c     |   12 ++++++++++--
 net/netfilter/xt_recent.c      |   11 +++++------
 net/netfilter/xt_socket.c      |   21 ++++++++++++---------
 4 files changed, 28 insertions(+), 18 deletions(-)
