From: Marcus Meissner <meissner@suse.de>
Subject: [PATCH] net/ipv6: check for mistakenly passed in non-AF_INET6 sockaddrs
Date: Mon, 6 Jun 2011 18:00:07 +0200
Message-ID: <20110606160007.GD28535@suse.de>
References: <20110525155918.GA27869@suse.de> <20110601.210359.2079286191194442010.davem@davemloft.net> <alpine.LNX.2.00.1106061538210.13876@nitsch.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Reinhard Max <max@suse.de>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:46530 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757587Ab1FFQAK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jun 2011 12:00:10 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1106061538210.13876@nitsch.suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 06, 2011 at 03:47:30PM +0200, Reinhard Max wrote:
> 
> On Wed, 1 Jun 2011 at 21:03, David Miller wrote:
> 
> >Since we haven't been validating the sin_family field for 18+ years, 
> >the chance to break some applications is very real.
> >
> >But I think it's more important to fix this (and force any broken 
> >apps to set sin_family correctly).  So I will apply this, thanks.
> 
> I think a corresponding check should also go into inet6_bind() in 
> net/ipv6/af_inet6.c .

Good idea,

Same check as for IPv4, also do for IPv6.

(If you passed in a IPv4 sockaddr_in here, the sizeof check
 in the line before would have triggered already though.)

Signed-off-by: Marcus Meissner <meissner@suse.de>
Cc: Reinhard Max <max@suse.de>

Ciao, Marcus
---
 net/ipv6/af_inet6.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index b7919f9..d450a2f 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -272,6 +272,10 @@ int inet6_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 
 	if (addr_len < SIN6_LEN_RFC2133)
 		return -EINVAL;
+
+	if (addr->sin6_family != AF_INET6)
+		return -EINVAL;
+
 	addr_type = ipv6_addr_type(&addr->sin6_addr);
 	if ((addr_type & IPV6_ADDR_MULTICAST) && sock->type == SOCK_STREAM)
 		return -EINVAL;
-- 
1.7.4.1

