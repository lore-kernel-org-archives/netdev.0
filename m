From: Mathias Krause <mathias.krause@secunet.com>
Subject: [PATCH net-next 0/3] IPsec improvements
Date: Tue,  5 Nov 2013 14:54:08 +0100
Message-ID: <cover.1381923854.git.mathias.krause@secunet.com>
Cc: Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>,
	netdev@vger.kernel.org, Mathias Krause <mathias.krause@secunet.com>
To: "David S. Miller" <davem@davemloft.net>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:52539 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754733Ab3KENyX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Nov 2013 08:54:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series moves pskb_put() to the core code -- making the code
duplication in caif obsolete (patches 1 and 2).

Additionally does this series optimize the IPsec receive path in patch 3
by allowing skb_cow_data() to leave the buffer fragmented. I noticed the
linearization to be a bottleneck when doing some VPN gateway benchmarks.
Linearization of the buffer isn't needed in the receive path as the
crypto API (and all other users of skb_cow_data) can handle sg.

With patch 3 applied I was able to increase the throughput of an IPsec
gateway from 7.12 Gbit/s to 7.28 Gbit/s.


Please apply!

Mathias Krause (3):
  net: move pskb_put() to core code
  caif: use pskb_put() instead of reimplementing its functionality
  net: allow to leave the buffer fragmented in skb_cow_data()

 include/linux/skbuff.h  |    1 +
 include/net/esp.h       |    2 -
 net/caif/cfpkt_skbuff.c |   12 +----------
 net/core/skbuff.c       |   52 +++++++++++++++++++++++++++++++++++++----------
 net/xfrm/xfrm_algo.c    |   13 -----------
 5 files changed, 43 insertions(+), 37 deletions(-)

-- 
1.7.2.5
