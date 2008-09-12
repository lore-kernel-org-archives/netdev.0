From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH 2.6.28] tcp_ipv6: fix use of uninitialized memory
Date: Fri, 12 Sep 2008 09:44:05 -0300
Message-ID: <20080912124405.GF8935@ghostprotocols.net>
References: <20080912070525.GA22276@damson.getinternet.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org
To: Vegard Nossum <vegard.nossum@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:47974 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752728AbYILMxy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Sep 2008 08:53:54 -0400
Content-Disposition: inline
In-Reply-To: <20080912070525.GA22276@damson.getinternet.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Fri, Sep 12, 2008 at 09:05:25AM +0200, Vegard Nossum escreveu:
> >From 6544c4074aa5dde2e3f4d3e02f5601c1c33b770e Mon Sep 17 00:00:00 2001
> From: Vegard Nossum <vegard.nossum@gmail.com>
> Date: Tue, 9 Sep 2008 07:17:32 +0200
> Subject: [PATCH] tcp_ipv6: fix use of uninitialized memory
> 
> inet6_rsk() is called on a struct request_sock * before we
> have checked whether the socket is an ipv6 socket or a ipv6-
> mapped ipv4 socket. The access that triggers this is the
> inet_rsk(rsk)->inet6_rsk_offset dereference in inet6_rsk().
> 
> This is arguably not a critical error as the inet6_rsk_offset
> is only used to compute a pointer which is never really used
> (in the code path in question) anyway. But it might be a
> latent error, so let's fix it.
> 
> Spotted by kmemcheck.

Humm, so this was poisoned at allocation and then when inet6_rsk_offset
was accessed it noticed, interesting, thanks!

Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>
 
- Arnaldo
