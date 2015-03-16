From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: pull request (net): ipsec 2015-03-16
Date: Mon, 16 Mar 2015 07:52:21 +0100
Message-ID: <1426488744-17104-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:57363 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750822AbbCPGxE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Mar 2015 02:53:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1) Fix the network header offset in _decode_session6
   when multiple IPv6 extension headers are present.
   From Hajime Tazaki.

2) Fix an interfamily tunnel crash. We set outer mode
   protocol too early and may dispatch to the wrong
   address family. Move the setting of the outer mode
   protocol behind the last accessing of the inner mode
   to fix the crash.

3) Most callers of xfrm_lookup() expect that dst_orig
   is released on error. But xfrm_lookup_route() may
   need dst_orig to handle certain error cases. So
   introduce a flag that tells what should be done in
   case of error. From Huaibin Wang.

Please pull or let me know if there are problems.

Thanks!

The following changes since commit 59343cd7c4809cf7598789e1cd14563780ae4239:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2015-01-27 13:55:36 -0800)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec.git master

for you to fetch changes up to ac37e2515c1a89c477459a2020b6bfdedabdb91b:

  xfrm: release dst_orig in case of error in xfrm_lookup() (2015-02-12 07:10:56 +0100)

----------------------------------------------------------------
Hajime Tazaki (1):
      xfrm6: Fix a offset value for network header in _decode_session6

Steffen Klassert (1):
      xfrm: Fix local error reporting crash with interfamily tunnels

huaibin Wang (1):
      xfrm: release dst_orig in case of error in xfrm_lookup()

 include/net/dst.h       |  1 +
 net/ipv4/xfrm4_output.c |  2 +-
 net/ipv6/xfrm6_output.c |  2 +-
 net/ipv6/xfrm6_policy.c |  1 +
 net/xfrm/xfrm_policy.c  | 12 ++++++------
 5 files changed, 10 insertions(+), 8 deletions(-)
