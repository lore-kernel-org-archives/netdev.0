From: Jussi Maki <jmaki@sisapiiri.net.net>
Subject: Re: [PATCH] xfrm: xfrm hash to use Jenkins' hash
Date: Thu, 6 Aug 2009 11:58:55 +0300 (EEST)
Message-ID: <alpine.DEB.1.10.0908061147060.3426@sisapiiri.net.net>
References: <ce10d01f0908050041p43c308fav72ac640f665e161f@mail.gmail.com> <20090805.120831.66033097.davem@davemloft.net> <ce10d01f0908052332o1db16460k58ed47849670c6de@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jussi Maki <joamaki@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sisapiiri.net ([62.142.224.56]:36679 "EHLO sisapiiri.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752859AbZHFJIF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Aug 2009 05:08:05 -0400
In-Reply-To: <ce10d01f0908052332o1db16460k58ed47849670c6de@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,

Did some testing and one possible fix to this problem
would be to change the xor to addition. Would this be OK?

---
 net/xfrm/xfrm_hash.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/xfrm/xfrm_hash.h b/net/xfrm/xfrm_hash.h
index d401dc8..e5195c9 100644
--- a/net/xfrm/xfrm_hash.h
+++ b/net/xfrm/xfrm_hash.h
@@ -16,7 +16,7 @@ static inline unsigned int __xfrm6_addr_hash(xfrm_address_t *addr)
 
 static inline unsigned int __xfrm4_daddr_saddr_hash(xfrm_address_t *daddr, xfrm_address_t *saddr)
 {
-	return ntohl(daddr->a4 ^ saddr->a4);
+	return ntohl(daddr->a4 + saddr->a4);
 }
 
 static inline unsigned int __xfrm6_daddr_saddr_hash(xfrm_address_t *daddr, xfrm_address_t *saddr)
-- 
1.5.6.5

On Thu, 6 Aug 2009, Jussi Maki wrote:

> Hi David,
> 
> Changing the (h >> 16) to ((h >> 16) ^ (h >> 24)) still has the same
> problem as given in the example,
> that is if you have a set of transports with incrementing addresses
> (192.168.0.1-172.16.0.1, 192.168.0.2-172.16.0.2,..) they
> still hash to the same value. The reason to this is that it's doing
> src^dst in __xfrm4_daddr_saddr_hash.
> 
> Should I pursue with fixing the inlining issue in my patch or would
> you have any suggestions how I could
> fix this by perhaps modifying __xfrm4_daddr_saddr_hash?
