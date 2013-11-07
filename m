From: Mathias Krause <mathias.krause@secunet.com>
Subject: [PATCHv2 next-next 0/3] move pskb_put (was: IPsec improvements)
Date: Thu,  7 Nov 2013 14:18:23 +0100
Message-ID: <1383830306-16697-1-git-send-email-mathias.krause@secunet.com>
Cc: Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	Mathias Krause <mathias.krause@secunet.com>
To: "David S. Miller" <davem@davemloft.net>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:55202 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751083Ab3KGNSi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Nov 2013 08:18:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series moves pskb_put() to the core code, making the code
duplication in caif obsolete (patches 1 and 2).
Patch 3 fixes a few kernel-doc issues.

v2 of this series does no longer contain the skb_cow_data() patch and
therefore no performance improvements for IPsec. The change is still
under discussion, but otherwise independent from the above changes.

Please apply!

v2:
- kernel-doc fixes for pskb_put, as noticed by Ben
- dropped skb_cow_data patch as it's still discussed
- added a kernel-doc fixes patch (patch 3)

Mathias Krause (3):
  net: move pskb_put() to core code
  caif: use pskb_put() instead of reimplementing its functionality
  net: skbuff - kernel-doc fixes

 include/linux/skbuff.h  |    3 ++-
 include/net/esp.h       |    2 --
 net/caif/cfpkt_skbuff.c |   12 +-----------
 net/core/skbuff.c       |   33 ++++++++++++++++++++++++++++-----
 net/xfrm/xfrm_algo.c    |   13 -------------
 5 files changed, 31 insertions(+), 32 deletions(-)

-- 
1.7.2.3
