From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][IPV6]: Make sure fib6_rule_lookup doesn't return NULL
Date: Tue, 08 Aug 2006 16:43:45 -0700 (PDT)
Message-ID: <20060808.164345.91207648.davem@davemloft.net>
References: <44D90AA0.1000408@tcs.hut.fi>
	<20060808221651.GS14627@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vnuorval@tcs.hut.fi, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:52099
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030337AbWHHXnl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 19:43:41 -0400
To: tgraf@suug.ch
In-Reply-To: <20060808221651.GS14627@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Wed, 9 Aug 2006 00:16:51 +0200

> * Ville Nuorvala <vnuorval@tcs.hut.fi> 2006-08-09 01:05
> >     [IPV6]: Make sure fib6_rule_lookup doesn't return NULL
> >     
> >     The callers of fib6_rule_lookup don't expect it to return NULL,
> >     therefore it must return ip6_null_entry whenever fib_rule_lookup fails.
> >     
> >     Signed-off-by: Ville Nuorvala <vnuorval@tcs.hut.fi>
> 
> I think it would be a lot cleaner to return an error code
> like fib_lookup() and save the atomic operations. We only
> destroy the dst again anyway in case of a failure.

Yes, the current scheme is a poor substitute for IS_ERR/PTR_ERR.

But for now let's fix the bug and apply Ville's patch.
