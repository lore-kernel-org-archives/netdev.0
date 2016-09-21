From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: pull request (net): ipsec 2016-09-21
Date: Wed, 21 Sep 2016 13:05:42 +0200
Message-ID: <1474455946-674-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:38330 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754413AbcIULF4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 21 Sep 2016 07:05:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1) Propagate errors on security context allocation.
   From Mathias Krause.

2) Fix inbound policy checks for inter address family tunnels.
   From Thomas Zeitlhofer.

3) Fix an old memory leak on aead algorithm usage.
   From Ilan Tayari.

4) A recent patch fixed a possible NULL pointer dereference
   but broke the vti6 input path.
   Fix from Nicolas Dichtel.

Please pull or let me know if there are problems.

Thanks!

The following changes since commit 2c2c8e33e4aa6e46f19ef7bba8e559759a74a4db:

  Merge branch 'nfp-fixes' (2016-09-08 17:18:42 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec.git master

for you to fetch changes up to 63c43787d35e45562a6b5927e2edc8f4783d95b8:

  vti6: fix input path (2016-09-21 10:09:14 +0200)

----------------------------------------------------------------
Ilan Tayari (1):
      xfrm: Fix memory leak of aead algorithm name

Mathias Krause (1):
      xfrm_user: propagate sec ctx allocation errors

Nicolas Dichtel (1):
      vti6: fix input path

thomas.zeitlhofer+lkml@ze-it.at (1):
      vti: use right inner_mode for inbound inter address family policy checks

 include/net/xfrm.h      |  4 +++-
 net/ipv4/ip_vti.c       | 15 ++++++++++++++-
 net/ipv6/ip6_vti.c      | 19 +++++++++++++++----
 net/ipv6/xfrm6_input.c  | 16 +++++++++++-----
 net/ipv6/xfrm6_tunnel.c |  2 +-
 net/xfrm/xfrm_state.c   |  1 +
 net/xfrm/xfrm_user.c    |  9 ++++++---
 7 files changed, 51 insertions(+), 15 deletions(-)
