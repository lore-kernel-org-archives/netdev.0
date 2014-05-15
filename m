From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: pull request (net): ipsec 2014-05-15
Date: Thu, 15 May 2014 09:07:50 +0200
Message-ID: <1400137676-27565-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:44782 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753792AbaEOHIN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 May 2014 03:08:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This pull request has a merge conflict in net/ipv4/ip_vti.c
between commit 8d89dcdf80d8 ("vti: don't allow to add the same
tunnel twice") and commit a32452366b72  ("vti4:Don't count header
length twice"). It can be solved like it is done in linux-next.

1) Fix a ipv6 xfrm output crash when a packet is rerouted
   by netfilter to not use IPsec.

2) vti4 counts some header lengths twice leading to an incorrect
   device mtu. Fix this by counting these headers only once.

3) We don't catch the case if an unsupported protocol is submitted
   to the xfrm protocol handlers, this can lead to NULL pointer
   dereferences. Fix this by adding the appropriate checks.

4) vti6 may unregister pernet ops twice on init errors.
   Fix this by removing one of the calls to do it only once.
   From Mathias Krause.

5) Set the vti tunnel mark before doing a lookup in the error
   handlers. Otherwise we don't find the correct xfrm state.

Please pull or let me know if there are problems.

Thanks!

The following changes since commit d80e773f16f66a610e04f6875d4da84e74a8fb6c:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf (2014-04-06 11:29:59 -0400)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec.git master

for you to fetch changes up to 6d004d6cc73920299adf4cfe25010b348fc94395:

  vti: Use the tunnel mark for lookup in the error handlers. (2014-05-12 09:36:03 +0200)

----------------------------------------------------------------
Mathias Krause (1):
      vti6: Don't unregister pernet ops twice on init errors

Steffen Klassert (5):
      xfrm: Fix crash with ipv6 IPsec tunnel and NAT.
      vti4: Don't count header length twice.
      xfrm4: Properly handle unsupported protocols
      xfrm6: Properly handle unsupported protocols
      vti: Use the tunnel mark for lookup in the error handlers.

 net/ipv4/ip_vti.c         |    6 ++++--
 net/ipv4/xfrm4_output.c   |   32 ++++++++++++++++++--------------
 net/ipv4/xfrm4_protocol.c |   19 +++++++++++++++++--
 net/ipv6/ip6_vti.c        |    8 ++++----
 net/ipv6/xfrm6_output.c   |   22 +++++++++++++---------
 net/ipv6/xfrm6_protocol.c |   11 ++++++++++-
 6 files changed, 66 insertions(+), 32 deletions(-)
