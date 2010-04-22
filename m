From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/3] IPv6: Generic TTL Security Mechanism (original
 version)
Date: Thu, 22 Apr 2010 09:23:05 -0700
Message-ID: <20100422092305.0e45f547@nehalam>
References: <20100403232103.923025940@vyatta.com>
	<20100403232922.489187907@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Pekka Savola <pekkas@netcore.fi>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Nick Hilliard <nick@inex.ie>, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:38187 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751918Ab0DVQXR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Apr 2010 12:23:17 -0400
In-Reply-To: <20100403232922.489187907@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 03 Apr 2010 16:21:04 -0700
Stephen Hemminger <shemminger@vyatta.com> wrote:

> This patch adds IPv6 support for RFC5082 Generalized TTL
> Security Mechanism.  
> 
> The original proposed code; the IPV6 and IPV4 socket options are seperate.
> With this method, the server does have to deal with both IPv4 and IPv6
> socket options and the client has to handle the different for each
> family.
> 
> On client:
> 	int ttl = 255;
> 	getaddrinfo(argv[1], argv[2], &hint, &result);
> 
> 	for (rp = result; rp != NULL; rp = rp->ai_next) {
> 		s = socket(rp->ai_family, rp->ai_socktype, rp->ai_protocol);
> 		if (s < 0) continue;
> 
> 		if (rp->ai_family == AF_INET) {
> 			setsockopt(s, IPPROTO_IP, IP_TTL, &ttl, sizeof(ttl));
> 		} else if (rp->ai_family == AF_INET6) {
> 			setsockopt(s, IPPROTO_IPV6,  IPV6_UNICAST_HOPS, 
> 					&ttl, sizeof(ttl)))
> 		}
> 			
> 		if (connect(s, rp->ai_addr, rp->ai_addrlen) == 0) {
> 		   ...
> 
> On server:
> 	int minttl = 255 - maxhops;
>    
> 	getaddrinfo(NULL, port, &hints, &result);
> 	for (rp = result; rp != NULL; rp = rp->ai_next) {
> 		s = socket(rp->ai_family, rp->ai_socktype, rp->ai_protocol);
> 		if (s < 0) continue;
> 
> 		if (rp->ai_family == AF_INET6)
> 			setsockopt(s, IPPROTO_IPV6,  IPV6_MINHOPCOUNT,
> 					&minttl, sizeof(minttl));
> 		setsockopt(s, IPPROTO_IP, IP_MINTTL, &minttl, sizeof(minttl));
> 			
> 		if (bind(s, rp->ai_addr, rp->ai_addrlen) == 0)
> 			break
> ..
> 
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Dave: Yoshifuji and I agree this is the best solution, how come the patch
hasn't been applied?
