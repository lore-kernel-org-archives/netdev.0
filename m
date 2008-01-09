From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [NET] ROUTE: fix rcu_dereference() uses in /proc/net/rt_cache
Date: Wed, 09 Jan 2008 18:36:09 +0100
Message-ID: <47850609.905@cosmosbay.com>
References: <20080109094637.GA28874@gondor.apana.org.au>	<20080109113727.50eae500.dada1@cosmosbay.com>	<20080109142258.GC13714@linux.vnet.ibm.com> <20080109.063126.68241252.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: paulmck@linux.vnet.ibm.com, herbert@gondor.apana.org.au,
	dipankar@in.ibm.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp21.orange.fr ([80.12.242.47]:6320 "EHLO smtp21.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754566AbYAIRgQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 12:36:16 -0500
Received: from me-wanadoo.net (localhost [127.0.0.1])
	by mwinf2109.orange.fr (SMTP Server) with ESMTP id AE3871C00095
	for <netdev@vger.kernel.org>; Wed,  9 Jan 2008 18:36:14 +0100 (CET)
In-Reply-To: <20080109.063126.68241252.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
> Date: Wed, 9 Jan 2008 06:22:58 -0800
>
>  =20
>> On Wed, Jan 09, 2008 at 11:37:27AM +0100, Eric Dumazet wrote:
>>    =20
>>> On Wed, 9 Jan 2008 20:46:37 +1100
>>> Herbert Xu <herbert@gondor.apana.org.au> wrote:
>>>
>>> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
>>> index d337706..28484f3 100644
>>> --- a/net/ipv4/route.c
>>> +++ b/net/ipv4/route.c
>>> @@ -283,12 +283,12 @@ static struct rtable *rt_cache_get_first(stru=
ct seq_file *seq)
>>>  			break;
>>>  		rcu_read_unlock_bh();
>>>  	}
>>> -	return r;
>>> +	return rcu_dereference(r);
>>>  }
>>>      =20
>> Would it be possible to tag rt_cache_get_first() with an __acquires(=
RCU)
>> to help out sparse?
>>    =20
>
> Sparse can't handle conditional locking very well, as is done here.
> There is a seperate thread where Eric reworks how all of this
> locking is done in order to pacify sparse and be able to add the
> __acquires() etc. tags and some of us found it too ugly to
> swallow :-)
>
>  =20

I will post a patch series to address this point after next merge=20
(net-2.6 -> net-2.6.25)

Thank you




