From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 0/2] Netfilter fixes for net
Date: Thu, 20 Nov 2014 13:30:49 +0100
Message-ID: <1416486651-12271-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:41541 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756658AbaKTMfg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Nov 2014 07:35:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

The following patchset contains two bugfixes for your net tree, they ar=
e:

1) Validate netlink group from nfnetlink to avoid an out of bound array
   access. This should only happen with superuser priviledges though.
   Discovered by Andrey Ryabinin using trinity.

2) Don't push ethernet header before calling the netfilter output hook
   for multicast traffic, this breaks ebtables since it expects to see
   skb->data pointing to the network header, patch from Linus Luessing.

You can pull these changes from:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Thanks!

----------------------------------------------------------------

The following changes since commit feb91a02ccb09661507f170b2a444aec94f3=
07f9:

  ipv6: mld: fix add_grhead skb_over_panic for devs with large MTUs (20=
14-11-16 16:55:06 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

for you to fetch changes up to f0b4eeced518c632210ef2aea44fc92cc9e86cce=
:

  bridge: fix netfilter/NF_BR_LOCAL_OUT for own, locally generated quer=
ies (2014-11-17 12:38:02 +0100)

----------------------------------------------------------------
Linus L=C3=BCssing (1):
      bridge: fix netfilter/NF_BR_LOCAL_OUT for own, locally generated =
queries

Pablo Neira Ayuso (1):
      netfilter: nfnetlink: fix insufficient validation in nfnetlink_bi=
nd

 net/bridge/br_multicast.c |    3 +--
 net/netfilter/nfnetlink.c |   12 +++++++++++-
 2 files changed, 12 insertions(+), 3 deletions(-)
