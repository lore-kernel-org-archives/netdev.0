From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: pull request (net-next): ipsec-next 2014-09-25
Date: Thu, 25 Sep 2014 11:10:21 +0200
Message-ID: <1411636225-4433-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:54391 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752987AbaIYJKq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Sep 2014 05:10:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1) Remove useless hash_resize_mutex in xfrm_hash_resize().
   This mutex is used only there, but xfrm_hash_resize()
   can't be called concurrently at all. From Ying Xue.

2) Extend policy hashing to prefixed policies based on
   prefix lenght thresholds. From Christophe Gouault.

3) Make the policy hash table thresholds configurable
   via netlink. From Christophe Gouault.

4) Remove the maximum authentication length for AH.
   This was needed to limit stack usage. We switched
   already to allocate space, so no need to keep the
   limit. From Herbert Xu.

Please pull or let me know if there are problems.

Thanks!

The following changes since commit a3d1214688d5259a200414def4d38f1e4531febd:

  neigh: document gc_thresh2 (2014-08-25 17:37:10 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec-next.git master

for you to fetch changes up to 689f1c9de2abbd76fda224d12cea5f43568a4335:

  ipsec: Remove obsolete MAX_AH_AUTH_LEN (2014-09-18 10:54:36 +0200)

----------------------------------------------------------------
Christophe Gouault (2):
      xfrm: hash prefixed policies based on preflen thresholds
      xfrm: configure policy hash table thresholds by netlink

Herbert Xu (1):
      ipsec: Remove obsolete MAX_AH_AUTH_LEN

Ying Xue (1):
      xfrm: remove useless hash_resize_mutex locks

 include/net/ah.h          |   3 -
 include/net/netns/xfrm.h  |  14 +++++
 include/net/xfrm.h        |   1 +
 include/uapi/linux/xfrm.h |   7 +++
 net/ipv4/ah4.c            |   2 -
 net/ipv6/ah6.c            |   2 -
 net/xfrm/xfrm_hash.h      |  76 +++++++++++++++++++++----
 net/xfrm/xfrm_policy.c    | 140 ++++++++++++++++++++++++++++++++++++++++++++--
 net/xfrm/xfrm_state.c     |  13 +----
 net/xfrm/xfrm_user.c      |  83 +++++++++++++++++++++++++--
 10 files changed, 303 insertions(+), 38 deletions(-)
