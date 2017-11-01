From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: pull request (net): ipsec 2017-11-01
Date: Wed, 1 Nov 2017 11:05:00 +0100
Message-ID: <1509530703-12707-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:60028 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754251AbdKAKFU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 1 Nov 2017 06:05:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1) Fix a memleak when a packet matches a policy
   without a matching state.

2) Reset the socket cached dst_entry when inserting
   a socket policy, otherwise the policy might be
   ignored. From Jonathan Basseri.

3) Fix GSO for a IPsec, GRE tunnel combination.
   We reset the encapsulation field at the skb
   too erly, as a result GRE does not segment
   GSO packets. Fix this by resetting the the
   encapsulation field right before the
   transformation where the inner headers get
   invalid.

Please pull or let me know if there are problems.

Thanks!

The following changes since commit 864f5af3a3525f588391cd230cb8129ad758708e:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec (2017-10-24 20:17:47 +0900)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec.git master

for you to fetch changes up to 73b9fc49b4c0116a04eda3979f64ed9b540b153c:

  xfrm: Fix GSO for IPsec with GRE tunnel. (2017-10-31 09:20:35 +0100)

----------------------------------------------------------------
Jonathan Basseri (1):
      xfrm: Clear sk_dst_cache when applying per-socket policy.

Steffen Klassert (2):
      xfrm: Fix xfrm_dst_cache memleak
      xfrm: Fix GSO for IPsec with GRE tunnel.

 net/xfrm/xfrm_output.c | 4 +++-
 net/xfrm/xfrm_policy.c | 1 -
 net/xfrm/xfrm_state.c  | 1 +
 3 files changed, 4 insertions(+), 2 deletions(-)
