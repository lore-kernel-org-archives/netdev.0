From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: pull request (net): ipsec 2017-05-23
Date: Tue, 23 May 2017 07:33:39 +0200
Message-ID: <1495517624-27096-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:45112 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932860AbdEWFdx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 May 2017 01:33:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1) Fix wrong header offset for esp4 udpencap packets.

2) Fix a stack access out of bounds when creating a bundle
   with sub policies. From Sabrina Dubroca.

3) Fix slab-out-of-bounds in pfkey due to an incorrect
   sadb_x_sec_len calculation.

4) We checked the wrong feature flags when taking down
   an interface with IPsec offload enabled.
   Fix from Ilan Tayari.

5) Copy the anti replay sequence numbers when doing a state
   migration, otherwise we get out of sync with the sequence
   numbers. Fix from Antony Antony.

Please pull or let me know if there are problems.

Thanks!

The following changes since commit f411af6822182f84834c4881b825dd40534e7fe8:

  Merge branch 'ibmvnic-Updated-reset-handler-andcode-fixes' (2017-05-03 11:33:06 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec.git master

for you to fetch changes up to a486cd23661c9387fb076c3f6ae8b2aa9d20d54a:

  xfrm: fix state migration copy replay sequence numbers (2017-05-19 12:49:13 +0200)

----------------------------------------------------------------
Antony Antony (1):
      xfrm: fix state migration copy replay sequence numbers

Ilan Tayari (1):
      xfrm: Fix NETDEV_DOWN with IPSec offload

Sabrina Dubroca (1):
      xfrm: fix stack access out of bounds with CONFIG_XFRM_SUB_POLICY

Steffen Klassert (2):
      esp4: Fix udpencap for local TCP packets.
      af_key: Fix slab-out-of-bounds in pfkey_compile_policy.

 include/net/xfrm.h     | 10 ----------
 net/ipv4/esp4.c        |  5 ++++-
 net/key/af_key.c       |  2 +-
 net/xfrm/xfrm_device.c |  2 +-
 net/xfrm/xfrm_policy.c | 47 -----------------------------------------------
 net/xfrm/xfrm_state.c  |  2 ++
 6 files changed, 8 insertions(+), 60 deletions(-)
