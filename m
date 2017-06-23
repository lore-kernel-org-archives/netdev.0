From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: pull request (net): ipsec 2017-06-23
Date: Fri, 23 Jun 2017 09:06:28 +0200
Message-ID: <1498201594-10835-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:47046 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750821AbdFWHGm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 23 Jun 2017 03:06:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1) Fix xfrm garbage collecting when unregistering a netdevice.
   From Hangbin Liu.

2) Fix NULL pointer derefernce when exiting a network namespace.
   From Hangbin Liu.

3) Fix some error codes in pfkey to prevent a NULL pointer derefernce.
   From Dan Carpenter.

4) Fix NULL pointer derefernce on allocation failure in pfkey.
   From Dan Carpenter.

5) Adjust IPv6 payload_len to include extension headers. Otherwise
   we corrupt the packets when doing ESP GRO on transport mode.
   From Yossi Kuperman.

6) Set nhoff to the proper offset of the IPv6 nexthdr when doing ESP GRO.
   From Yossi Kuperman.

Please pull or let me know if there are problems.

Thanks!

The following changes since commit b29794ec95c6856b316c2295904208bf11ffddd9:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2017-06-06 14:30:17 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec.git master

for you to fetch changes up to ca3a1b856636f596c691ab5b3764045a142186db:

  esp6_offload: Fix IP6CB(skb)->nhoff for ESP GRO (2017-06-22 10:49:14 +0200)

----------------------------------------------------------------
Dan Carpenter (2):
      xfrm: Oops on error in pfkey_msg2xfrm_state()
      xfrm: NULL dereference on allocation failure

Hangbin Liu (2):
      xfrm: fix xfrm_dev_event() missing when compile without CONFIG_XFRM_OFFLOAD
      xfrm: move xfrm_garbage_collect out of xfrm_policy_flush

Yossi Kuperman (2):
      xfrm6: Fix IPv6 payload_len in xfrm6_transport_finish
      esp6_offload: Fix IP6CB(skb)->nhoff for ESP GRO

 include/net/xfrm.h      |  7 ++-----
 net/ipv6/esp6_offload.c | 25 +++++++++++++++++++++++++
 net/ipv6/xfrm6_input.c  |  2 +-
 net/key/af_key.c        | 19 +++++++++++++++----
 net/xfrm/Makefile       |  3 +--
 net/xfrm/xfrm_device.c  |  2 ++
 net/xfrm/xfrm_policy.c  |  4 ----
 net/xfrm/xfrm_user.c    |  1 +
 8 files changed, 47 insertions(+), 16 deletions(-)
