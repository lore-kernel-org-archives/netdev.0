From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: pull request (net-next): ipsec-next 2014-12-03
Date: Wed, 3 Dec 2014 11:04:56 +0100
Message-ID: <1417601101-18625-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:33441 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751401AbaLCKFW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Dec 2014 05:05:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1) Fix a set but not used warning. From Fabian Frederick.

2) Currently we make sequence number values available to userspace
   only if we use ESN. Make the sequence number values also available
   for non ESN states. From Zhi Ding.

3) Remove socket policy hashing. We don't need it because socket
   policies are always looked up via a linked list. From Herbert Xu.

4) After removing socket policy hashing, we can use __xfrm_policy_link
   in xfrm_policy_insert. From Herbert Xu.

5) Add a lookup method for vti6 tunnels with wildcard endpoints.
   I forgot this when I initially implemented vti6.
   
Please pull or let me know if there are problems.

Thanks!

The following changes since commit 49cc91f919e2a94df8c9f99aae9b405444e88624:

  Merge branch 's390-next' (2014-10-26 22:21:45 -0400)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec-next.git master

for you to fetch changes up to fbe68ee87522f6eaa10f9076c0a7117e1613f2f7:

  vti6: Add a lookup method for tunnels with wildcard endpoints. (2014-11-20 10:03:07 +0100)

----------------------------------------------------------------
Fabian Frederick (1):
      xfrm: fix set but not used warning in xfrm_policy_queue_process()

Herbert Xu (2):
      xfrm: Do not hash socket policies
      xfrm: Use __xfrm_policy_link in xfrm_policy_insert

Steffen Klassert (1):
      vti6: Add a lookup method for tunnels with wildcard endpoints.

dingzhi (1):
      xfrm: add XFRMA_REPLAY_VAL attribute to SA messages

 include/net/netns/xfrm.h |  4 ++--
 net/ipv6/ip6_vti.c       | 17 ++++++++++++++++
 net/xfrm/xfrm_policy.c   | 52 +++++++++++++++++++++++++++---------------------
 net/xfrm/xfrm_user.c     | 12 +++++++----
 4 files changed, 56 insertions(+), 29 deletions(-)
