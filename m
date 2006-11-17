From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH]Fix BUG of ip_rt_send_redirect()
Date: Fri, 17 Nov 2006 17:49:34 +1100
Message-ID: <E1GkxXa-00055c-00@gondolin.me.apana.org.au>
References: <009301c70a0b$9d6fdb20$6004a8c0@weiyongjun>
Cc: shemminger@osdl.org, lyw@nanjing-fnst.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:22790 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1755494AbWKQGts
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Nov 2006 01:49:48 -0500
To: yjwei@nanjing-fnst.com (Wei Yongjun)
In-Reply-To: <009301c70a0b$9d6fdb20$6004a8c0@weiyongjun>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Wei Yongjun <yjwei@nanjing-fnst.com> wrote:
> 
> Yes, time_after() works correctly for values that wraparound. For examples: if 
> time a = (unsigned long)(-1), and time b = 1; time_after(b, a) = true.
> But if a is increaseing, after a circle of jiffies, a' = a + (unsigned long)(-1) 
> + 1 = (unsigned long)(-1) = a,
> this time a' is after b, but time_after(b, a') still equal to true,because 
> values that wraparound can not be making in time_after().

I think there are two problems here:

1) The first time we hit the check rate_last is zero.  We should simply
proceed with the redirect rather than treating this as a jiffies value.

2) When a dst is so old that the jiffies have wrapped around.  I'm
not sure whether this is worth solving as it should be extremely rare
unless your HZ is sufficiently large and you're on a 32-bit platform.

One solution would be to periodically reset the rate_last fields to
their original states.  Perhaps we can combine that with the GC.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
