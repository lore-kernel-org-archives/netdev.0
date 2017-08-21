From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: pull request (net): ipsec 2017-08-21
Date: Mon, 21 Aug 2017 08:07:59 +0200
Message-ID: <1503295683-19153-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:35446 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750937AbdHUGIJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Aug 2017 02:08:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1) Fix memleaks when ESP takes an error path.

2) Fix null pointer dereference when creating a sub policy
   that matches the same outer flow as main policy does.
   From Koichiro Den.

3) Fix possible out-of-bound access in xfrm_migrate.
   This patch should go to the stable trees too.
   From Vladis Dronov.

4) ESP can return positive and negative error values,
   so treat both cases as an error.

Please pull or let me know if there are problems.

Thanks!

The following changes since commit edaf3825182958a1fd5e39708fcb6ea48eca2060:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2017-07-12 19:30:57 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec.git master

for you to fetch changes up to 4ff0308f06da5016aafb05330ed37809b54f81ae:

  esp: Fix error handling on layer 2 xmit. (2017-08-07 08:31:07 +0200)

----------------------------------------------------------------
Koichiro Den (1):
      xfrm: fix null pointer dereference on state and tmpl sort

Steffen Klassert (2):
      esp: Fix memleaks on error paths.
      esp: Fix error handling on layer 2 xmit.

Vladis Dronov (1):
      xfrm: policy: check policy direction value

 net/ipv4/esp4.c         | 13 ++++++++-----
 net/ipv4/esp4_offload.c |  2 +-
 net/ipv6/esp6.c         |  9 +++++----
 net/ipv6/esp6_offload.c |  2 +-
 net/xfrm/xfrm_policy.c  |  6 ++++++
 net/xfrm/xfrm_state.c   |  8 ++++++++
 6 files changed, 29 insertions(+), 11 deletions(-)
