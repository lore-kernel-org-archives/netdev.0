From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/7] netfilter fixes for net
Date: Thu, 21 Nov 2013 10:05:21 +0100
Message-ID: <1385024728-4057-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:34516 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751133Ab3KUJF7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Nov 2013 04:05:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David!

The following patchset contains fixes for your net tree, they are:

* Remove extra quote from connlimit configuration in Kconfig, from
  Randy Dunlap.

* Fix missing mss option in syn packets sent to the backend in our
  new synproxy target, from Martin Topholm.

* Use window scale announced by client when sending the forged
  syn to the backend, from Martin Topholm.

* Fix IPv6 address comparison in ebtables, from Lu=C3=ADs Fernando
  Cornachioni Estrozi.

* Fix wrong endianess in sequence adjustment which breaks helpers
  in NAT configurations, from Phil Oester.

* Fix the error path handling of nft_compat, from me.

* Make sure the global conntrack counter is decremented after the
  object has been released, also from me.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

Thanks!

----------------------------------------------------------------

The following changes since commit 42a2d923cc349583ebf6fdd52a7d35e1c2f7=
e6bd:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next (2=
013-11-13 17:40:34 +0900)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

for you to fetch changes up to acab78b99633f12aa2b697474562e19c5718a1ca=
:

  netfilter: ebt_ip6: fix source and destination matching (2013-11-19 1=
5:33:29 +0100)

----------------------------------------------------------------
Lu=C3=ADs Fernando Cornachioni Estrozi (1):
      netfilter: ebt_ip6: fix source and destination matching

Martin Topholm (2):
      netfilter: synproxy: send mss option to backend
      netfilter: synproxy: correct wscale option passing

Pablo Neira Ayuso (2):
      netfilter: nft_compat: fix error path in nft_parse_compat()
      netfilter: nf_conntrack: decrement global counter after object re=
lease

Phil Oester (1):
      netfilter: fix wrong byte order in nf_ct_seqadj_set internal info=
rmation

Randy Dunlap (1):
      netfilter: fix connlimit Kconfig prompt string

 net/bridge/netfilter/ebt_ip6.c      |    8 +++++---
 net/ipv4/netfilter/ipt_SYNPROXY.c   |    1 +
 net/ipv6/netfilter/ip6t_SYNPROXY.c  |    1 +
 net/netfilter/Kconfig               |    2 +-
 net/netfilter/nf_conntrack_core.c   |    3 ++-
 net/netfilter/nf_conntrack_seqadj.c |    4 ++--
 net/netfilter/nf_synproxy_core.c    |    7 ++++---
 net/netfilter/nft_compat.c          |   19 +++++++++++++------
 8 files changed, 29 insertions(+), 16 deletions(-)
