From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: check rt_genid in dst_check
Date: Thu, 18 Mar 2010 22:16:49 -0700 (PDT)
Message-ID: <20100318.221649.02256374.davem@davemloft.net>
References: <1268912902-27050-1-git-send-email-timo.teras@iki.fi>
	<20100318121146.GA13307@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48152
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751305Ab0CSFQ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Mar 2010 01:16:27 -0400
In-Reply-To: <20100318121146.GA13307@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 18 Mar 2010 20:11:46 +0800

> On Thu, Mar 18, 2010 at 01:48:22PM +0200, Timo Teras wrote:
>> @@ -1726,7 +1726,9 @@ static void ip_rt_update_pmtu(struct dst_entry *dst, u32 mtu)
>>  
>>  static struct dst_entry *ipv4_dst_check(struct dst_entry *dst, u32 cookie)
>>  {
>> -	return NULL;
>> +	if (dst && dst->dev && rt_is_expired((struct rtable *) dst))
>> +		return NULL;
>> +	return dst;
>>  }
> 
> Can dst->dev ever be NULL? I'm pretty sure that we disallow that
> from ever happening through the use of the loopback device.  A
> quick grep also fails to find any other dst->dev NULL checks in
> this file.

Timo please respin with the NULL check removed, it just creates
confusion if one spot has the NULL check and not only is it
not needed, but also no other spots make this check.

Please remember to add in Herbert's ACK when reposting.

Thanks.
