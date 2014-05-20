From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/6] Netfilter/nftables fixes for net
Date: Tue, 20 May 2014 11:45:20 +0200
Message-ID: <1400579126-6451-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:40860 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750706AbaETJpj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 May 2014 05:45:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The following patchset contains nftables fixes for your net tree, they
are:

1) Fix crash when using the goto action in a rule by making sure that
   we always fall back on the base chain. Otherwise, this may try to
   access the counter memory area of non-base chains, which does not
   exists.

2) Fix several aspects of the rule tracing that are currently broken:

   * Reset rule number counter after goto/jump action, otherwise the
     tracing reports a bogus rule number.
   * Fix tracing of the goto action.
   * Fix bogus rule number counter after goto.
   * Fix missing return trace after finishing the walk through the
     non-base chain.
   * Fix missing trace when matching non-terminal rule.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Thanks!

----------------------------------------------------------------

The following changes since commit a8951d5814e1373807a94f79f7ccec7041325470:

  netfilter: Fix potential use after free in ip6_route_me_harder() (2014-05-09 02:36:39 +0200)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

for you to fetch changes up to 3b084e99a3fabaeb0f9c65a0806cde30f0b2835e:

  netfilter: nf_tables: fix trace of matching non-terminal rule (2014-05-15 19:44:20 +0200)

----------------------------------------------------------------
Pablo Neira Ayuso (6):
      netfilter: nf_tables: reset rule number counter after jump and goto
      netfilter: nf_tables: fix goto action
      netfilter: nf_tables: fix tracing of the goto action
      netfilter: nf_tables: fix bogus rulenum after goto action
      netfilter: nf_tables: fix missing return trace at the end of non-base chain
      netfilter: nf_tables: fix trace of matching non-terminal rule

 net/netfilter/nf_tables_core.c |   49 +++++++++++++++++++---------------------
 1 file changed, 23 insertions(+), 26 deletions(-)
