From: Werner Almesberger <werner@almesberger.net>
Subject: [PATCH net-next 1/2] icmpv6_filter: fix "_hdr" incorrectly being a
 pointer
Date: Fri, 2 Aug 2013 10:51:19 -0300
Message-ID: <45f3417354a033cf71cb5e70b5cdf8c9e542e234.1375417279.git.werner@almesberger.net>
References: <cover.1375417279.git.werner@almesberger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hydra.openmoko.org ([144.76.72.4]:60940 "EHLO
	hydra.openmoko.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753124Ab3HBNxI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Aug 2013 09:53:08 -0400
Received: from 201-160-231-201.fibertel.com.ar ([201.231.160.201] helo=ws)
	by hydra.openmoko.org with esmtpsa (TLS1.0:RSA_AES_128_CBC_SHA1:128)
	(Exim 4.80)
	(envelope-from <werner@almesberger.net>)
	id 1V5Fn0-0001fi-1Y
	for netdev@vger.kernel.org; Fri, 02 Aug 2013 15:53:07 +0200
Content-Disposition: inline
In-Reply-To: <cover.1375417279.git.werner@almesberger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"_hdr" should hold the ICMPv6 header while "hdr" is the pointer to it.
This worked by accident.

Signed-off-by: Werner Almesberger <werner@almesberger.net>
---
 net/ipv6/raw.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index c45f7a5..164fb5f 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -108,7 +108,7 @@ found:
  */
 static int icmpv6_filter(const struct sock *sk, const struct sk_buff *skb)
 {
-	struct icmp6hdr *_hdr;
+	struct icmp6hdr _hdr;
 	const struct icmp6hdr *hdr;
 
 	hdr = skb_header_pointer(skb, skb_transport_offset(skb),
-- 
1.8.1.2
