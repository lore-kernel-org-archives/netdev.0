From: "Li Yewang" <lyw@nanjing-fnst.com>
Subject: Re: [PATCH]Fix BUG of ip_rt_send_redirect()
Date: Wed, 29 Nov 2006 10:55:07 +0800
Message-ID: <00df01c71361$c81f04e0$2a01a8c0@liyewang>
References: <E1GkxXa-00055c-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="UTF-8";
	reply-type=original
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [221.6.14.228] ([221.6.14.228]:19354 "EHLO proxy.fnst.com.cn")
	by vger.kernel.org with ESMTP id S1756821AbWK2C5q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Nov 2006 21:57:46 -0500
To: "Herbert Xu" <herbert@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu herbert@gondor.apana.org.au wrote:

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

Mr Herbert Xu

Sorry for later reply

 I have some questions about your advice:
1) If the first time when we send the redirect packets, but the time_after(jiffies, b)==false.
     So the redirect packets can not be sended.
     This situation happens when the system of 32-bit boot on less than 5 minutes.
     This must be the kernel bug.

2) If the router used frequently, the garbage collect function can not free this dst. 
    Next time when we want this router to send redirect packets, and if the jiffies wraparound 
    and time_after(jiffies,b)==false, the redirect packets can not be sended. 
    So we must consider this situation and solve this problem.
        

> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
