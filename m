From: Brian Haley <brian.haley@hp.com>
Subject: Re: IPV6 raw socket denies bind(2)
Date: Wed, 27 Oct 2010 19:54:54 -0400
Message-ID: <4CC8BBCE.70609@hp.com>
References: <alpine.LNX.2.01.1010280000260.7820@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:24400 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753831Ab0J0Xy5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 19:54:57 -0400
In-Reply-To: <alpine.LNX.2.01.1010280000260.7820@obet.zrqbmnf.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/27/2010 06:01 PM, Jan Engelhardt wrote:
> int main(void)
> {
> 	struct sockaddr_in6 src = {};
> 	int sk;
> 
> 	sk = socket(AF_INET6, SOCK_RAW, IPPROTO_UDP);
> 	memset(&src, 0, sizeof(src));
> 	inet_pton(AF_INET6, "::1", &src);
> 	src.sin6_family = AF_INET6;
> 
> 	if (bind(sk, (void *)&src, sizeof(src)) < 0) {
> 		perror("bind");
> 		abort();
> 	}
> 	return 0;
> }

You're trashing the sockaddr, try this patch:

< 	inet_pton(AF_INET6, "::1", &src);
---
> 	inet_pton(AF_INET6, "::1", &src.sin6_addr);

-Brian
