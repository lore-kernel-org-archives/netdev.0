From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: pull request (net-next): ipsec-next 2017-02-01
Date: Wed, 1 Feb 2017 09:17:42 +0100
Message-ID: <1485937077-612-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:37042 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751696AbdBAISJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 1 Feb 2017 03:18:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1) Some typo fixes, from Alexander Alemayhu.

2) Don't acquire state lock in get_mtu functions.
   The only rece against a dead state does not matter.
   From Florian Westphal.

3) Remove xfrm4_state_fini, it is unused for more than
   10 years. From Florian Westphal.

4) Various rcu usage improvements. From Florian Westphal.

5) Properly handle crypto arrors in ah4/ah6.
   From Gilad Ben-Yossef.

6) Try to avoid skb linearization in esp4 and esp6.

7) The esp trailer is now set up in different places,
   add a helper for this.

8) With the upcomming usage of gro_cells in IPsec,
   a gro merged skb can have a secpath. Drop it
   before freeing or reusing the skb.

9) Add a xfrm dummy network device for napi. With
   this we can use gro_cells from within xfrm,
   it allows IPsec GRO without impact on the generic
   networking code.

Please pull or let me know if there are problems.

Thanks!

The following changes since commit 0a0a8d6b0e88d947d7ab3198b325e31f677bebc2:

  net: fealnx: use new api ethtool_{get|set}_link_ksettings (2017-01-02 16:59:10 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec-next.git master

for you to fetch changes up to 1995876a06bcf6f9f7d7b699bdbf387831679771:

  xfrm: Add a dummy network device for napi. (2017-01-30 06:45:43 +0100)

----------------------------------------------------------------
Alexander Alemayhu (1):
      xfrm: trivial typos

Florian Westphal (7):
      xfrm: state: do not acquire lock in get_mtu helpers
      xfrm: remove unused function
      xfrm: avoid rcu sparse warning
      xfrm: remove xfrm_state_put_afinfo
      xfrm: add and use xfrm_state_afinfo_get_rcu
      xfrm: state: simplify rcu_read_unlock handling in two spots
      xfrm: fix possible null deref in xfrm_init_tempstate

Gilad Ben-Yossef (2):
      IPsec: do not ignore crypto err in ah4 input
      IPsec: do not ignore crypto err in ah6 input

Steffen Klassert (5):
      esp4: Avoid skb_cow_data whenever possible
      esp6: Avoid skb_cow_data whenever possible
      esp: Introduce a helper to setup the trailer
      net: Drop secpath on free after gro merge.
      xfrm: Add a dummy network device for napi.

 include/net/xfrm.h     |   4 +-
 net/core/dev.c         |   2 +
 net/ipv4/ah4.c         |   3 +
 net/ipv4/esp4.c        | 332 ++++++++++++++++++++++++++++++++++++++-----------
 net/ipv4/xfrm4_state.c |   8 --
 net/ipv6/ah6.c         |   3 +
 net/ipv6/esp6.c        | 318 ++++++++++++++++++++++++++++++++++++----------
 net/xfrm/xfrm_input.c  |  12 +-
 net/xfrm/xfrm_output.c |   8 +-
 net/xfrm/xfrm_policy.c |   2 +-
 net/xfrm/xfrm_state.c  |  86 ++++++-------
 11 files changed, 578 insertions(+), 200 deletions(-)
