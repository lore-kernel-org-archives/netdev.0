From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: [PATCH net-next-2.6] ipv6: reduce per device ICMP mib sizes
Date: Thu, 19 May 2011 14:26:45 +0300
Message-ID: <08d4084d74a9299c4fd4d795394d4776@visp.net.lb>
References: <f9797bb034f650a24e927629d1ab77d8@visp.net.lb>
 <1305787158.3019.12.camel@edumazet-laptop>
 <1305788113.3019.19.camel@edumazet-laptop>
 <1305803663.3028.39.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rev-153-13.globalproof.net ([194.146.153.13]:52011 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752505Ab1ESL0t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 07:26:49 -0400
In-Reply-To: <1305803663.3028.39.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 On Thu, 19 May 2011 13:14:23 +0200, Eric Dumazet wrote:
> Le jeudi 19 mai 2011 =C3=A0 08:55 +0200, Eric Dumazet a =C3=A9crit :
>
>> Looking at snmp6_alloc_dev(), we allocate three mib per device :
>>
>> ipstats_mib  (30 * sizeof(u64) * number_of_possible_cpus)
>> icmpv6_mib    (4 * sizeof(long) * number_of_possible_cpus)
>> icmpv6msg_mib  (26 * sizeof(long))
>>
>
> Oops, I forgot that mibs were doubled (one set for USER, one set for=20
> BH)
>
> And :
> #define __ICMP6MSG_MIB_MAX 512
>
> So icmpv6msg_mib is really 512*sizeof(long)*number_of_possible_cpus*2
>
> 32 kbytes per device on a 8cpu machine, 32bit kernel.
>
> Plus all other mibs... yes thats way too big for a seldom used stuff.
>
> Here is patch I cooked and tested on my machine :
>
> [PATCH net-next-2.6] ipv6: reduce per device ICMP mib sizes.

 I'll test it tonight, thanks a lot :-)
 I guess it will help also for people with lot of interfaces=20
 (virtualisation?), not only ppp.

