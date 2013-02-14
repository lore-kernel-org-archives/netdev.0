From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: pull request (net-next): ipsec-next 2013-02-14
Date: Thu, 14 Feb 2013 12:47:20 +0100
Message-ID: <1360842447-3344-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:44514 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754455Ab3BNLrt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Feb 2013 06:47:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1) Remove a duplicated call to skb_orphan() in pf_key, from Cong Wang.

2) Prepare xfrm and pf_key for algorithms without pf_key support,
   from Jussi Kivilinna.

3) Fix an unbalanced lock in xfrm_output_one(), from Li RongQing.

4) Add an IPsec state resolution packet queue to handle
   packets that are send before the states are resolved.

5) xfrm4_policy_fini() is unused since 2.6.11, time to remove it.
   From Michal Kubecek.

6) The xfrm gc threshold was configurable just in the initial
   namespace, make it configurable in all namespaces. From
   Michal Kubecek.

7) We currently can not insert policies with mark and mask
   such that some flows would be matched from both policies.
   Allow this if the priorities of these policies are different,
   the one with the higher priority is used in this case.

Please pull or let me know if there are problems.

Thanks!

The following changes since commit cef401de7be8c4e155c6746bfccf721a4fa5fab9:

  net: fix possible wrong checksum generation (2013-01-28 00:27:15 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec-next.git master

for you to fetch changes up to 7cb8a93968e395e40a72a50da0b6114e752304b4:

  xfrm: Allow inserting policies with matching mark and different priorities (2013-02-11 14:07:01 +0100)

----------------------------------------------------------------
Cong Wang (1):
      af_key: remove a duplicated skb_orphan()

Jussi Kivilinna (1):
      pf_key/xfrm_algo: prepare pf_key and xfrm_algo for new algorithms without pfkey support

Li RongQing (1):
      xfrm: fix a unbalanced lock

Michal Kubecek (2):
      xfrm: remove unused xfrm4_policy_fini()
      xfrm: make gc_thresh configurable in all namespaces

Steffen Klassert (2):
      xfrm: Add a state resolution packet queue
      xfrm: Allow inserting policies with matching mark and different priorities

 include/net/dst.h        |    1 +
 include/net/netns/ipv4.h |    1 +
 include/net/netns/ipv6.h |    1 +
 include/net/xfrm.h       |   12 ++-
 net/ipv4/xfrm4_policy.c  |   58 ++++++++---
 net/ipv6/xfrm6_policy.c  |   52 +++++++++-
 net/key/af_key.c         |   40 ++++++--
 net/xfrm/xfrm_algo.c     |   65 ++++++++++--
 net/xfrm/xfrm_output.c   |    2 +-
 net/xfrm/xfrm_policy.c   |  247 ++++++++++++++++++++++++++++++++++++++++++++--
 10 files changed, 438 insertions(+), 41 deletions(-)
