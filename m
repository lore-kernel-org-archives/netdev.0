From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: pull request (net): ipsec 2016-09-08
Date: Thu, 8 Sep 2016 08:29:09 +0200
Message-ID: <1473316155-12186-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:35790 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751420AbcIHG3Z (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Sep 2016 02:29:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1) Fix a crash when xfrm_dump_sa returns an error.
   From Vegard Nossum.

2) Remove some incorrect WARN() on normal error handling.
   From Vegard Nossum.

3) Ignore socket policies when rebuilding hash tables,
   socket policies are not inserted into the hash tables.
   From Tobias Brunner.

4) Initialize and check tunnel pointers properly before
   we use it. From Alexey Kodanev.

5) Fix l3mdev oif setting on xfrm dst lookups.
   From David Ahern.

Please pull or let me know if there are problems.

Thanks!

The following changes since commit 8e6ce7ebeb34f0992f56de078c3744fb383657fa:

  net: cavium: liquidio: Avoid dma_unmap_single on uninitialized ndata (2016-07-16 22:06:00 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec.git master

for you to fetch changes up to 11d7a0bb95eaaba1741bb24a7c3c169c82f09c7b:

  xfrm: Only add l3mdev oif to dst lookups (2016-08-22 06:33:32 +0200)

----------------------------------------------------------------
Alexey Kodanev (1):
      net/xfrm_input: fix possible NULL deref of tunnel.ip6->parms.i_key

David Ahern (1):
      xfrm: Only add l3mdev oif to dst lookups

Tobias Brunner (1):
      xfrm: Ignore socket policies when rebuilding hash tables

Vegard Nossum (3):
      xfrm: fix crash in XFRM_MSG_GETSA netlink handler
      xfrm: get rid of incorrect WARN
      xfrm: get rid of another incorrect WARN

 net/ipv4/xfrm4_policy.c |  2 +-
 net/ipv6/xfrm6_input.c  |  1 +
 net/ipv6/xfrm6_policy.c |  2 +-
 net/xfrm/xfrm_input.c   | 14 +++++++-------
 net/xfrm/xfrm_policy.c  |  4 ++++
 net/xfrm/xfrm_user.c    | 13 ++++---------
 6 files changed, 18 insertions(+), 18 deletions(-)
