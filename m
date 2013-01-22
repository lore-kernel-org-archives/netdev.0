From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: pull request: ipsec 2013-01-22
Date: Tue, 22 Jan 2013 10:06:31 +0100
Message-ID: <1358845596-2066-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:33489 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752462Ab3AVJG6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jan 2013 04:06:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1) The transport header did not point to the right place after
   esp/ah processing on tunnel mode in the receive path. As a
   result, the ECN field of the inner header was not set correctly,
   fixes from Li RongQing.

2) We did a null check too late in one of the xfrm_replay advance
   functions. This can lead to a division by zero, fix from
   Nickolai Zeldovich.

3) The size calculation of the hash table missed the muiltplication
   with the actual struct size when the hash table is freed.
   We might call the wrong free function, fix from Michal Kubecek.

4) On IPsec pmtu events we can't access the transport headers of
   the original packet, so force a relookup for all routes
   to notify about the pmtu event.

Please pull or let me know if there are problems.

Thanks!

The following changes since commit c7e2e1d72ed7707239d20525e0ebcad7e3303659:

  ipv4: fix NULL checking in devinet_ioctl() (2013-01-06 21:11:18 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec.git master

for you to fetch changes up to 05ab86c55683410593720003442dde629782aaac:

  xfrm4: Invalidate all ipv4 routes on IPsec pmtu events (2013-01-21 12:43:54 +0100)

----------------------------------------------------------------
Li RongQing (2):
      ah4/esp4: set transport header correctly for IPsec tunnel mode.
      ah6/esp6: set transport header correctly for IPsec tunnel mode.

Michal Kubecek (1):
      xfrm: fix freed block size calculation in xfrm_policy_fini()

Nickolai Zeldovich (1):
      net/xfrm/xfrm_replay: avoid division by zero

Steffen Klassert (1):
      xfrm4: Invalidate all ipv4 routes on IPsec pmtu events

 net/ipv4/ah4.c         |   18 ++++++++++++++----
 net/ipv4/esp4.c        |   12 +++++++++---
 net/ipv4/ipcomp.c      |    7 +++++--
 net/ipv6/ah6.c         |   11 +++++++++--
 net/ipv6/esp6.c        |    5 ++++-
 net/xfrm/xfrm_policy.c |    2 +-
 net/xfrm/xfrm_replay.c |    4 +++-
 7 files changed, 45 insertions(+), 14 deletions(-)
