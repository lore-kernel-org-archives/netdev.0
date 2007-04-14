From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: kernel BUG at net/core/skbuff.c in linux-2.6.21-rc6
Date: Sat, 14 Apr 2007 16:00:12 +1000
Message-ID: <E1HcbIy-0006Pt-00@gondolin.me.apana.org.au>
References: <20070413.161635.26523891.davem@davemloft.net>
Cc: kaber@trash.net, poemann@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, paulus@samba.org
To: davem@davemloft.net (David Miller)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1495 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S964974AbXDNGAj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Apr 2007 02:00:39 -0400
In-Reply-To: <20070413.161635.26523891.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> wrote:
>
>> It seems we fail to reserve enough headroom for the case
>> buf[0] == PPP_ALLSTATIONS and buf[1] != PPP_UI.
>> 
>> Can you try this patch please?
> 
> Any confirmation of this fix yet?

FWIW the fix definitely looks correct (the bug has been there for
years at least) and it does match the crash dump.  In fact, there
is only a single skb_push (the only thing that can generate an under
panic) in ppp_async.c and this is the one that Patrick has fixed.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
