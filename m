From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: pull request (net): ipsec 2014-09-22
Date: Mon, 22 Sep 2014 07:38:38 +0200
Message-ID: <1411364320-5309-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:51333 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751272AbaIVFjO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Sep 2014 01:39:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We generate a blackhole or queueing route if a packet
matches an IPsec policy but a state can't be resolved.
Here we assume that dst_output() is called to kill
these packets. Unfortunately this assumption is not
true in all cases, so it is possible that these packets
leave the system without the necessary transformations.

This pull request contains two patches to fix this issue:

1) Fix for blackhole routed packets.

2) Fix for queue routed packets.

Both patches are serious stable candidates.

Please pull or let me know if there are problems.

Thanks!

The following changes since commit 95cd6f488d164de462a8279e802a0ad05c33d167:

  scsi: fix build errors, SCSI_FC_ATTRS needs to depend on SCSI && NET (2014-09-16 00:06:57 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec.git master

for you to fetch changes up to b8c203b2d2fc961bafd53b41d5396bbcdec55998:

  xfrm: Generate queueing routes only from route lookup functions (2014-09-16 10:08:49 +0200)

----------------------------------------------------------------
Steffen Klassert (2):
      xfrm: Generate blackhole routes only from route lookup functions
      xfrm: Generate queueing routes only from route lookup functions

 include/net/dst.h      | 16 +++++++++++++++-
 net/ipv4/route.c       |  6 +++---
 net/ipv6/ip6_output.c  |  4 ++--
 net/xfrm/xfrm_policy.c | 48 ++++++++++++++++++++++++++++++++++++++++--------
 4 files changed, 60 insertions(+), 14 deletions(-)
