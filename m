From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: pull request (net): ipsec 2013-11-01
Date: Fri,  1 Nov 2013 09:21:44 +0100
Message-ID: <1383294107-7509-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:49467 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750928Ab3KAIVw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Nov 2013 04:21:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1) Fix a possible race on ipcomp scratch buffers because
   of too early enabled siftirqs. From Michal Kubecek.

2) The current xfrm garbage collector threshold is too small
   for some workloads, resulting in bad performance on these
   workloads. Increase the threshold from 1024 to 32768.

3) Some codepaths might not have a dst_entry attached to the
   skb when calling xfrm_decode_session(). So add a check
   to prevent a null pointer dereference in this case.

Please pull or let me know if there are problems.

Thanks!

The following changes since commit e9e4ea74f06635f2ffc1dffe5ef40c854faa0a90:

  net: smc91x: dont't use SMC_outw for fixing up halfword-aligned data (2013-10-11 17:50:59 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec.git master

for you to fetch changes up to 84502b5ef9849a9694673b15c31bd3ac693010ae:

  xfrm: Fix null pointer dereference when decoding sessions (2013-11-01 07:08:46 +0100)

----------------------------------------------------------------
Michal Kubecek (1):
      xfrm: prevent ipcomp scratch buffer race condition

Steffen Klassert (2):
      xfrm: Increase the garbage collector threshold
      xfrm: Fix null pointer dereference when decoding sessions

 net/ipv4/xfrm4_policy.c |    8 ++++++--
 net/ipv6/xfrm6_policy.c |    8 ++++++--
 net/xfrm/xfrm_ipcomp.c  |   12 ++++++------
 3 files changed, 18 insertions(+), 10 deletions(-)
