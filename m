From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH RFC] ipv6: fix route selection if kernel is not compiled
 with CONFIG_IPV6_ROUTER_PREF
Date: Wed, 10 Jul 2013 16:10:58 +0200
Message-ID: <51DD6B72.1050700@6wind.com>
References: <20130707173031.GC9625@order.stressinduktion.org> <20130709215701.GD9763@order.stressinduktion.org> <51DD1352.8000705@6wind.com> <51DD2959.9060206@6wind.com> <20130710105316.GA5735@order.stressinduktion.org> <51DD521F.1000905@6wind.com> <20130710132122.GD15411@order.stressinduktion.org>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	petrus.lt@gmail.com, davem@davemloft.net,
	hannes@stressinduktion.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:52510 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752561Ab3GJOLD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jul 2013 10:11:03 -0400
Received: by mail-wi0-f175.google.com with SMTP id m6so11439772wiv.14
        for <netdev@vger.kernel.org>; Wed, 10 Jul 2013 07:11:01 -0700 (PDT)
In-Reply-To: <20130710132122.GD15411@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 10/07/2013 15:21, Hannes Frederic Sowa a =C3=A9crit :
> On Wed, Jul 10, 2013 at 02:22:55PM +0200, Nicolas Dichtel wrote:
>> Le 10/07/2013 12:53, Hannes Frederic Sowa a =C3=A9crit :
>>> On Wed, Jul 10, 2013 at 11:28:57AM +0200, Nicolas Dichtel wrote:
>>>> Le 10/07/2013 09:54, Nicolas Dichtel a =C3=A9crit :
>>>>> Le 09/07/2013 23:57, Hannes Frederic Sowa a =C3=A9crit :
>>>>>> After starting a ping6 2000::1 the box should panic soon, after =
the
>>>>>> first nexthop entry times out.
>>>>>>
>>>>>> Perhaps you could give me a hint?
>>>>> I will run some tests with your patch. Will see.
>>>> I don't reproduce this panic.
>>>
>>> I just dumped the routes for which it does increase the rt6i_nsibli=
ngs
>>> counter in this condition:
>>>
>>>                          /* If we have the same destination and the=
 same
>>>                          metric,
>>>                           * but not the same gateway, then the rout=
e we
>>>                           try to
>>>                           * add is sibling to this route, increment=
 our
>>>                           counter
>>>                           * of siblings, and later we will add our =
route
>>>                           to the
>>>                           * list.
>>>                           * Only static routes (which don't have fl=
ag
>>>                           * RTF_EXPIRES) are used for ECMPv6.
>>>                           *
>>>                           * To avoid long list, we only had sibling=
s if the
>>>                           * route have a gateway.
>>>                           */
>>>                          if (rt->rt6i_flags & RTF_GATEWAY &&
>>>                              !(rt->rt6i_flags & RTF_EXPIRES) &&
>>>                              !(iter->rt6i_flags & RTF_EXPIRES))
>>>                                  rt->rt6i_nsiblings++;
>>>                                  dump_route(iter, "(iter)");
>>>                                  dump_route(rt, "(rt)");
>>> 			}
>>>
>>>
>>>
>>> Here:
>>>
>>> [   42.497470] (iter): ffff88011796cc00 dst 2000::1 plen 128 gatewa=
y
>>> 2001:db8::32, siblings 2, metric 0, expires 0 gateway 2 idev6
>>> ffff8801139ddc00 dev ffff880117e83000
>>> [   42.505912] (rt): ffff88011796d800 dst 2000::1 plen 128 gateway
>>> fe80::5054:ff:fe82:e153, siblings 1, metric 0, expires 0 gateway 2 =
idev6
>>> ffff880117edc400 dev ffff8801185cb000
>>> [   42.527241] (iter): ffff88011796d380 dst 2000::1 plen 128 gatewa=
y
>>> 2001:db8::33, siblings 2, metric 0, expires 0 gateway 2 idev6
>>> ffff8801139ddc00 dev ffff880117e83000
>>> [   42.536440] (rt): ffff88011796d800 dst 2000::1 plen 128 gateway
>>> fe80::5054:ff:fe82:e153, siblings 2, metric 0, expires 0 gateway 2 =
idev6
>>> ffff880117edc400 dev ffff8801185cb000
>>>
>>>  From my understanding these two routes should not be aggregated in=
 one
>>> ecmp
>>> route set. Am I seeing this correct? (My configuration is like in t=
he mail
>>> before.)
>> Hmm, why?
>> Routes have the same destination, same metric, are static (expires =3D=
=3D 0)
>> and have a gateway.
>
> The route with rt6i_gateway does actually expire because I got it fro=
m
> autoconf and ip -6 r l confirms this, too. It seems this is only the =
cached
> route (I will confirm shortly). Is this still ok?
I wonder why expires is 0. Even if this route is cached, the flag RTF_E=
XPIRES=20
should be set. Am I wrong?


Nicolas
