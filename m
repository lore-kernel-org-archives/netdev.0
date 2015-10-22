From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: pull request (net): ipsec 2015-10-22
Date: Thu, 22 Oct 2015 08:07:15 +0200
Message-ID: <1445494039-2612-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:50518 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751295AbbJVGH2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Oct 2015 02:07:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1) Fix IPsec pre-encap fragmentation for GSO packets.
   From Herbert Xu.

2) Fix some header checks in _decode_session6.
   We skip the header informations if the data pointer points
   already behind the header in question for some protocols.
   This is because we call pskb_may_pull with a negative value
   converted to unsigened int from pskb_may_pull in this case.
   Skipping the header informations can lead to incorrect policy
   lookups. From Mathias Krause.

3) Allow to change the replay threshold and expiry timer of a
   state without having to set other attributes like replay
   counter and byte lifetime. Changing these other attributes
   may break the SA. From Michael Rossberg.

4) Fix pmtu discovery for local generated packets.
   We may fail dispatch to the inner address family.
   As a reault, the local error handler is not called
   and the mtu value is not reported back to userspace.

Please pull or let me know if there are problems.

Thanks!

The following changes since commit 724a7636ad026a3a68f3fc626ccd04111f65cfd9:

  Merge branch 'sctp-fixes' (2015-09-03 15:43:06 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec.git master

for you to fetch changes up to ca064bd89363a6e7e71b1c5226ff1b718957a9d4:

  xfrm: Fix pmtu discovery for local generated packets. (2015-10-19 10:30:05 +0200)

----------------------------------------------------------------
Herbert Xu (1):
      ipv6: Fix IPsec pre-encap fragmentation check

Mathias Krause (1):
      xfrm6: Fix ICMPv6 and MH header checks in _decode_session6

Michael Rossberg (1):
      xfrm: Fix state threshold configuration from userspace

Steffen Klassert (1):
      xfrm: Fix pmtu discovery for local generated packets.

 net/ipv4/xfrm4_output.c |  2 ++
 net/ipv6/xfrm6_output.c | 18 ++++++++++++------
 net/ipv6/xfrm6_policy.c |  6 ++++--
 net/xfrm/xfrm_user.c    |  4 +++-
 4 files changed, 21 insertions(+), 9 deletions(-)
