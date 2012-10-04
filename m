From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: [PATCH] udp: port starting location not random
Date: Thu, 04 Oct 2012 15:06:34 -0700 (PDT)
Message-ID: <0a842600-9707-4465-a5ea-6acfb38a9a70@tahiti.vyatta.com>
References: <1349387874.21172.5.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:40171 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753557Ab2JDWGf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Oct 2012 18:06:35 -0400
In-Reply-To: <1349387874.21172.5.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nevermind, it depends on random being big enough. This shows that it
works with large enough random(). The hash I was getting from VXLAN
was too small...

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

int main(int ac, char **av) {
	int low, high, remaining;
	unsigned int rand;
	unsigned short first;
	
	low = atoi(av[1]);
	high = atoi(av[2]);
	remaining = (high - low) + 1;
	srandom(getpid());
	rand = (uint32_t) random();
	
	first = (((uint64_t)rand * remaining) >> 32) + low;

	printf("%d %d %u => %u\n", low, high, rand, first);
	return 0;
}
