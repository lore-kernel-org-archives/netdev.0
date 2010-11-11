From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] macvlan: lockless tx path
Date: Thu, 11 Nov 2010 10:13:31 -0800
Message-ID: <4CDC324B.40206@candelatech.com>
References: <1289403709.2860.216.camel@edumazet-laptop>	 <4CDAD8C8.20807@candelatech.com>	 <1289411027.2860.248.camel@edumazet-laptop>	 <4CDADC17.6070506@candelatech.com>	 <1289413120.2469.12.camel@edumazet-laptop>	 <4CDAE713.7020309@candelatech.com>	 <1289421187.2469.127.camel@edumazet-laptop> <4CDB1021.507@candelatech.com>	 <1289427705.17691.52.camel@edumazet-laptop>	 <4CDB226A.8080903@candelatech.com>	 <1289432184.17691.141.camel@edumazet-laptop>	 <4CDB2EBC.2090905@candelatech.com>	 <1289459012.17691.1001.camel@edumazet-laptop>	 <4CDC1C9A.3070102@candelatech.com>	 <1289494618.17691.1498.camel@edumazet-laptop>	 <4CDC25F5.7010501@candelatech.com> <1289498572.17691.1599.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:60691 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752492Ab0KKSNe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Nov 2010 13:13:34 -0500
In-Reply-To: <1289498572.17691.1599.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/11/2010 10:02 AM, Eric Dumazet wrote:
> Le jeudi 11 novembre 2010 =C3=A0 09:20 -0800, Ben Greear a =C3=A9crit=
 :
>
>> I've shown you my algorithm that requires one to know the counter
>> width, and in response you offered on that will work with 32 OR 64 b=
its,
>> as long as you make some assumptions.
>>
>> If you have an algorithm that can properly deal with wrapped counter=
s of
>> arbitrary bits, then post it.
>>
>
> Its only a generalization of RRD algo
>
> No rocket science I am afraid.
>
> You can try all the numbers in `seq 32 64` in this order, to get a
> generic algo.

Ok, so then you have to sample soon enough that a 32-bit counter
can't wrap twice..otherwise you couldn't tell a 32 bit from a
33 bit counter, and you basically gain nothing from having "64-bit"
stats.

And that still assumes at least 32-bit stats..not 16 or whatever.
Thankfully, I doubt there are any drivers using < 32 bit stats.

I'll work on a patch for my idea when I get a chance..we'll see if
anyone likes it.

If you are aware of any drivers that return counters of other than 32 o=
r
64bit widths, please let us know and perhaps we can fix them as well.

Thanks,
Ben

--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

