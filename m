From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: pull request (net): ipsec 2017-03-06
Date: Mon, 6 Mar 2017 07:57:25 +0100
Message-ID: <1488783448-12588-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:35430 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752796AbdCFG55 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 6 Mar 2017 01:57:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1) Fix lockdep splat on xfrm policy subsystem initialization.
   From Florian Westphal.

2) When using socket policies on IPv4-mapped IPv6 addresses,
   we access the flow informations of the wrong address family
   what leads to an out of bounds access. Fix this by using
   the family we get with the dst_entry, like we do it for the
   standard policy lookup.

3) vti6 can report a PMTU below IPV6_MIN_MTU. Fix this by
   adding a check for that before sending a ICMPV6_PKT_TOOBIG
   message.

Please pull or let me know if there are problems.

Thanks!

The following changes since commit 075ad765ef7541b2860de8408c165a92b78aefa3:

  net: thunderx: Fix PHY autoneg for SGMII QLM mode (2017-02-08 15:47:37 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec.git master

for you to fetch changes up to e3dc847a5f85b43ee2bfc8eae407a7e383483228:

  vti6: Don't report path MTU below IPV6_MIN_MTU. (2017-02-16 07:51:42 +0100)

----------------------------------------------------------------
Florian Westphal (1):
      xfrm: policy: init locks early

Steffen Klassert (2):
      xfrm: Don't use sk_family for socket policy lookups
      vti6: Don't report path MTU below IPV6_MIN_MTU.

 net/ipv6/ip6_vti.c     |  8 ++++++--
 net/xfrm/xfrm_policy.c | 19 +++++++++----------
 2 files changed, 15 insertions(+), 12 deletions(-)
