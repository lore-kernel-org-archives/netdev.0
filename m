From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: pull request (net): ipsec 2017-10-09
Date: Mon, 9 Oct 2017 09:16:35 +0200
Message-ID: <1507533399-29399-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:49542 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753947AbdJIHQs (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 9 Oct 2017 03:16:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1) Fix some error paths of the IPsec offloading API.

2) Fix a NULL pointer dereference when IPsec is used
   with vti. From Alexey Kodanev.

3) Don't call xfrm_policy_cache_flush under xfrm_state_lock,
   it triggers several locking warnings. From Artem Savkov.

Please pull or let me know if there are problems.

Thanks!

The following changes since commit 1f4f554a72be0d8c164c2f5bc6ba939a1c624fb4:

  net: qualcomm: rmnet: Fix a double free (2017-09-09 14:33:27 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec.git master

for you to fetch changes up to dd269db84908d4d3f7c0efed85bf9d8939fb0b9b:

  xfrm: don't call xfrm_policy_cache_flush under xfrm_state_lock (2017-09-28 09:39:05 +0200)

----------------------------------------------------------------
Alexey Kodanev (1):
      vti: fix NULL dereference in xfrm_input()

Artem Savkov (1):
      xfrm: don't call xfrm_policy_cache_flush under xfrm_state_lock

Steffen Klassert (2):
      xfrm: Fix deletion of offloaded SAs on failure.
      xfrm: Fix negative device refcount on offload failure.

 net/xfrm/xfrm_device.c | 1 +
 net/xfrm/xfrm_input.c  | 6 ++++--
 net/xfrm/xfrm_state.c  | 4 ++--
 net/xfrm/xfrm_user.c   | 1 +
 4 files changed, 8 insertions(+), 4 deletions(-)
