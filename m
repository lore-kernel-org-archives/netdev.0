From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: pull request (net): ipsec 2017-08-29
Date: Tue, 29 Aug 2017 12:31:27 +0200
Message-ID: <1504002694-1931-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:50640 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751238AbdH2Kbm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 29 Aug 2017 06:31:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1) Fix dst_entry refcount imbalance when using socket policies.
   From Lorenzo Colitti.

2) Fix locking when adding the ESP trailers.

3) Fix tailroom calculation for the ESP trailer by using
   skb_tailroom instead of skb_availroom.

4) Fix some info leaks in xfrm_user.
   From Mathias Krause.

Please pull or let me know if there are problems.

Thanks!

The following changes since commit 2b33bc8aa236b75d6e86a8a79126fd9739e4a5bd:

  net: dsa: use consume_skb() (2017-08-23 22:13:34 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec.git master

for you to fetch changes up to 931e79d7a7ddee4709c56b39de169a36804589a1:

  xfrm_user: fix info leak in build_aevent() (2017-08-28 10:58:02 +0200)

----------------------------------------------------------------
Lorenzo Colitti (1):
      net: xfrm: don't double-hold dst when sk_policy in use.

Mathias Krause (4):
      xfrm_user: fix info leak in copy_user_offload()
      xfrm_user: fix info leak in xfrm_notify_sa()
      xfrm_user: fix info leak in build_expire()
      xfrm_user: fix info leak in build_aevent()

Steffen Klassert (2):
      esp: Fix locking on page fragment allocation
      esp: Fix skb tailroom calculation

 net/ipv4/esp4.c        | 7 ++++---
 net/ipv6/esp6.c        | 7 ++++---
 net/xfrm/xfrm_policy.c | 1 -
 net/xfrm/xfrm_user.c   | 6 +++++-
 4 files changed, 13 insertions(+), 8 deletions(-)
