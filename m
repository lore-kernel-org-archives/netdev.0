From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: pull request (net-next): ipsec-next 2013-11-01
Date: Fri,  1 Nov 2013 08:50:53 +0100
Message-ID: <1383292257-4634-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:49094 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752488Ab3KAHvI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Nov 2013 03:51:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This pull request has a trivial merge conflict between git commit
e7d8f6c ("xfrm: Add refcount handling to queued policies") and
git commit 4d53eff ("xfrm: Don't queue retransmitted packets if
the original is still on the host"). It can be solved as it is
currently done in linux-next.

1) Use vmalloc_node for ipcomp percpu scratches to get proper
   NUMA affinity, from Eric Dumazet

2) Avoid to retransmit packets if the original packet is
   still in the xfrm hold queue.

3) Remove unused padlen field from struct esp_data.
   From Mathias Krause.

4) Remove struct esp_data because now it consists of a single
   pointer. From Mathias Krause.

Please pull or let me know if there are problems.

Thanks!

The following changes since commit 5bf47256f5433a9a5782754664e5ea04acb0537d:

  Merge tag 'batman-adv-for-davem' of git://git.open-mesh.org/linux-merge (2013-10-19 19:52:42 -0400)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec-next.git master

for you to fetch changes up to 1c5ad13f7c2b2afe30e43858d04fff979dc9d243:

  net: esp{4,6}: get rid of struct esp_data (2013-10-29 06:39:42 +0100)

----------------------------------------------------------------
Eric Dumazet (1):
      xfrm: use vmalloc_node() for percpu scratches

Mathias Krause (2):
      net: esp{4,6}: remove padlen from struct esp_data
      net: esp{4,6}: get rid of struct esp_data

Steffen Klassert (1):
      xfrm: Don't queue retransmitted packets if the original is still on the host

 include/net/esp.h      |   10 ----------
 net/ipv4/esp4.c        |   49 +++++++++++++++---------------------------------
 net/ipv6/esp6.c        |   48 +++++++++++++++--------------------------------
 net/xfrm/xfrm_ipcomp.c |    6 ++++--
 net/xfrm/xfrm_policy.c |    7 +++++++
 5 files changed, 41 insertions(+), 79 deletions(-)
