From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH][IPV6]: Make sure fib6_rule_lookup doesn't return NULL
Date: Wed, 9 Aug 2006 00:16:51 +0200
Message-ID: <20060808221651.GS14627@postel.suug.ch>
References: <44D90AA0.1000408@tcs.hut.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:57476 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1030324AbWHHWQa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2006 18:16:30 -0400
To: Ville Nuorvala <vnuorval@tcs.hut.fi>
Content-Disposition: inline
In-Reply-To: <44D90AA0.1000408@tcs.hut.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Ville Nuorvala <vnuorval@tcs.hut.fi> 2006-08-09 01:05
>     [IPV6]: Make sure fib6_rule_lookup doesn't return NULL
>     
>     The callers of fib6_rule_lookup don't expect it to return NULL,
>     therefore it must return ip6_null_entry whenever fib_rule_lookup fails.
>     
>     Signed-off-by: Ville Nuorvala <vnuorval@tcs.hut.fi>

I think it would be a lot cleaner to return an error code
like fib_lookup() and save the atomic operations. We only
destroy the dst again anyway in case of a failure.
