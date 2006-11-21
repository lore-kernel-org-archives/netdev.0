From: "Li Yewang" <lyw@nanjing-fnst.com>
Subject: Re: [PATCH]Fix BUG of ip_rt_send_redirect()
Date: Tue, 21 Nov 2006 11:07:25 +0800
Message-ID: <00e801c70d1a$2d14d800$7a04a8c0@liyewang>
References: <E1GkxXa-00055c-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="gb2312";
	reply-type=original
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [221.6.14.228] ([221.6.14.228]:49897 "EHLO proxy.fnst.com.cn")
	by vger.kernel.org with ESMTP id S966903AbWKUDKL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Nov 2006 22:10:11 -0500
To: "Herbert Xu" <herbert@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Yes, the first time when router want to send redirect packet,
We should send the redirect packet simply and do not regard the jiffies.
But the kernel has bugs as follow:
1.The kernel can not send the redirect packet at the begin 5 minutes 
  when the system boot(32bit machine).

2.In a circle of jiffies, router has 24.9 days can not send redirect packet.

I think my patch can solve the bugs.



Herbert Xu <herbert@gondor.apana.org.au> wrote:
> I think there are two problems here:
> 
> 1) The first time we hit the check rate_last is zero.  We should simply
> proceed with the redirect rather than treating this as a jiffies value.
> 
> 2) When a dst is so old that the jiffies have wrapped around.  I'm
> not sure whether this is worth solving as it should be extremely rare
> unless your HZ is sufficiently large and you're on a 32-bit platform.
> 
> One solution would be to periodically reset the rate_last fields to
> their original states.  Perhaps we can combine that with the GC.
> 
> Cheers,
> -- 
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

