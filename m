From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: pull request (net-next): ipsec-next 2017-08-21
Date: Mon, 21 Aug 2017 07:49:25 +0200
Message-ID: <1503294573-10206-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:34900 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751064AbdHUFtm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Aug 2017 01:49:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1) Support RX checksum with IPsec crypto offload for esp4/esp6.
   From Ilan Tayari.

2) Fixup IPv6 checksums when doing IPsec crypto offload.
   From Yossi Kuperman.

3) Auto load the xfrom offload modules if a user installs
   a SA that requests IPsec offload. From Ilan Tayari.

4) Clear RX offload informations in xfrm_input to not
   confuse the TX path with stale offload informations.
   From Ilan Tayari.

5) Allow IPsec GSO for local sockets if the crypto operation
   will be offloaded.

6) Support setting of an output mark to the xfrm_state.
   This mark can be used to to do the tunnel route lookup.
   From Lorenzo Colitti.

Please pull or let me know if there are problems.

Thanks!

The following changes since commit cb5b136c0095d434cb63495da8efb6a3d663a38f:

  Merge branch 'dsa-rework-EEE-support' (2017-08-01 20:09:10 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec-next.git master

for you to fetch changes up to 077fbac405bfc6d41419ad6c1725804ad4e9887c:

  net: xfrm: support setting an output mark. (2017-08-11 07:03:00 +0200)

----------------------------------------------------------------
Ilan Tayari (4):
      esp4: Support RX checksum with crypto offload
      esp6: Support RX checksum with crypto offload
      xfrm: Auto-load xfrm offload modules
      xfrm: Clear RX SKB secpath xfrm_offload

Lorenzo Colitti (1):
      net: xfrm: support setting an output mark.

Steffen Klassert (1):
      net: Allow IPsec GSO for local sockets

Yossi Kuperman (2):
      xfrm6: Fix CHECKSUM_COMPLETE after IPv6 header push
      esp6: Fix RX checksum after header pull

 include/net/xfrm.h        | 32 ++++++++++++++++++++++++++++----
 include/uapi/linux/xfrm.h |  1 +
 net/core/sock.c           |  2 +-
 net/ipv4/esp4.c           | 14 +++++++++++---
 net/ipv4/esp4_offload.c   |  5 ++++-
 net/ipv4/xfrm4_policy.c   | 14 +++++++++-----
 net/ipv6/esp6.c           | 16 +++++++++++++---
 net/ipv6/esp6_offload.c   |  5 ++++-
 net/ipv6/xfrm6_input.c    |  4 +++-
 net/ipv6/xfrm6_policy.c   |  9 ++++++---
 net/xfrm/xfrm_device.c    |  5 +++--
 net/xfrm/xfrm_input.c     |  2 ++
 net/xfrm/xfrm_output.c    |  3 +++
 net/xfrm/xfrm_policy.c    | 17 +++++++++--------
 net/xfrm/xfrm_state.c     | 16 ++++++++++++----
 net/xfrm/xfrm_user.c      | 13 ++++++++++++-
 16 files changed, 121 insertions(+), 37 deletions(-)
