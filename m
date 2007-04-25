From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] netdev: get rid of casts
Date: Wed, 25 Apr 2007 10:56:38 +1000
Message-ID: <E1HgVoE-00021H-00@gondolin.me.apana.org.au>
References: <462E4764.6000107@garzik.org>
Cc: shemminger@linux-foundation.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: jeff@garzik.org (Jeff Garzik)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1381 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754670AbXDYA45 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2007 20:56:57 -0400
In-Reply-To: <462E4764.6000107@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik <jeff@garzik.org> wrote:
>
>> @@ -2778,12 +2778,12 @@ int dev_ioctl(unsigned int cmd, void __user *arg)
>>  
>>       if (cmd == SIOCGIFCONF) {
>>               rtnl_lock();
>> -             ret = dev_ifconf((char __user *) arg);
>> +             ret = dev_ifconf(arg);
>>               rtnl_unlock();
>> -             return ret;
>>       }
>> +
>>       if (cmd == SIOCGIFNAME)
>> -             return dev_ifname((struct ifreq __user *)arg);
>> +             return dev_ifname(arg);
> 
> Seems like a net loss of information, with your patch.
> 
> The casts are adding missing type information, in this case.  Certainly 
> it is more for human consumption than compiler consumption, but 
> nonetheless...

How about just getting rid of the casts? 'arg' is already void * to
begin with.
 
Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
