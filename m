From: Arnaud Ebalard <arno@natisbad.org>
Subject: [PATCHv3 net-next-2.6 0/5] XFRM,IPv6: Removal of RH2/HAO from IPsec-protected MIPv6 traffic
Date: Wed, 29 Sep 2010 11:05:24 +0200
Message-ID: <cover.1285749610.git.arno@natisbad.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from copper.chdir.org ([88.191.97.87]:38509 "EHLO copper.chdir.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752794Ab0I2JE2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Sep 2010 05:04:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This an updated version of the patches. For reference, introduction of
the feature is here http://thread.gmane.org/gmane.linux.network/172941

This version 3 now also builds with ipv6 modular. To do that, a helper
(input_addr_check()) has been added to struct xfrm_state_afinfo. To
avoid the penalty of xfrm_state_get/put_afinfo() calls from xfrm_input(),
I spent some time in the sources and came up with the idea of accessing
it safely as follows:

 x = xfrm_state_lookup(net, skb->mark, NULL, spi, nexthdr, family);
 if (x == NULL ||
     x->outer_mode->afinfo->input_addr_check(skb, x)) {
     ...

Tell me if I missed something.

Comments welcome.

Cheers,

a+
