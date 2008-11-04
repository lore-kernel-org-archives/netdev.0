From: arno@natisbad.org (Arnaud Ebalard)
Subject: [PATCH] Have af-specific init_tempsel() initialize family field of temporary selector
Date: Tue, 04 Nov 2008 11:24:51 +0100
Message-ID: <87hc6npz4c.fsf@natisbad.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>,
	Andreas Steffen <andreas.steffen@strongswan.org>,
	Martin Willi <martin@strongswan.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moog.chdir.org ([88.191.42.160]:33045 "EHLO moog.chdir.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750733AbYKDK0m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Nov 2008 05:26:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

While adding MIGRATE support to strongSwan, Andreas Steffen noticed that
the selectors provided in XFRM_MSG_ACQUIRE have their family field
uninitialized (those in MIGRATE do have their family set).

Looking at the code, this is because the af-specific init_tempsel()
(called via afinfo->init_tempsel() in xfrm_init_tempsel()) do not set
the value.

Even if current apps probably do not rely on it, is there any argument
for not doing it or is it just an omission?

The patch below is more for discussion than anything else.

Cheers,

a+

Reported-by: Andreas Steffen <andreas.steffen@strongswan.org>
Signed-off-by: Arnaud Ebalard <arno@natisbad.org>
---
 net/ipv4/xfrm4_state.c |    1 +
 net/ipv6/xfrm6_state.c |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/xfrm4_state.c b/net/ipv4/xfrm4_state.c
index 07735ed..55dc6be 100644
--- a/net/ipv4/xfrm4_state.c
+++ b/net/ipv4/xfrm4_state.c
@@ -33,6 +33,7 @@ __xfrm4_init_tempsel(struct xfrm_state *x, struct flowi *fl,
 	x->sel.dport_mask = htons(0xffff);
 	x->sel.sport = xfrm_flowi_sport(fl);
 	x->sel.sport_mask = htons(0xffff);
+	x->sel.family = AF_INET;
 	x->sel.prefixlen_d = 32;
 	x->sel.prefixlen_s = 32;
 	x->sel.proto = fl->proto;
diff --git a/net/ipv6/xfrm6_state.c b/net/ipv6/xfrm6_state.c
index 89884a4..60c78cf 100644
--- a/net/ipv6/xfrm6_state.c
+++ b/net/ipv6/xfrm6_state.c
@@ -34,6 +34,7 @@ __xfrm6_init_tempsel(struct xfrm_state *x, struct flowi *fl,
 	x->sel.dport_mask = htons(0xffff);
 	x->sel.sport = xfrm_flowi_sport(fl);
 	x->sel.sport_mask = htons(0xffff);
+	x->sel.family = AF_INET6;
 	x->sel.prefixlen_d = 128;
 	x->sel.prefixlen_s = 128;
 	x->sel.proto = fl->proto;
-- 
1.5.6.3

