From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: ipv6: a question about ECMP
Date: Fri, 08 Nov 2013 11:09:59 +0100
Message-ID: <527CB877.6050800@6wind.com>
References: <527B6C70.3010507@cn.fujitsu.com>	<20131107121602.GI8144@order.stressinduktion.org> <CACP96tRh345x4D1BqpOK2eWfoeVbqMnu-+jGfF7eyFC1dbQoug@mail.gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: sowmini varadhan <sowmini05@gmail.com>,
	Duan Jiong <duanj.fnst@cn.fujitsu.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f47.google.com ([74.125.82.47]:34706 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756930Ab3KHKKC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 05:10:02 -0500
Received: by mail-wg0-f47.google.com with SMTP id c11so1721746wgh.14
        for <netdev@vger.kernel.org>; Fri, 08 Nov 2013 02:10:01 -0800 (PST)
In-Reply-To: <CACP96tRh345x4D1BqpOK2eWfoeVbqMnu-+jGfF7eyFC1dbQoug@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 07/11/2013 19:32, sowmini varadhan a =E9crit :
> On Thu, Nov 7, 2013 at 7:16 AM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
>> Hi Duan!
>>
>> On Thu, Nov 07, 2013 at 06:33:20PM +0800, Duan Jiong wrote:
>>>    After reading the ip6_pol_route(), i have a question about ECMP.=
 Why we call
>>> the rt6_multipath_select() after calling rt6_select()?
>>>    In my opinion, the route returned by rt6_select() has a highest =
score, but the route
>>> returned by rt6_multipath_select() may has a lower score than the f=
ormer, because the
>>> ECMP don't take the route preference into consideration. That means=
 that the kernel will
>>> choose a less-desirable route.
>>
>> ECMP routes only differ in the gateway the specify, so I doubt there=
 will be
>> any change in the score they woud receive. rt6_multipath_select does=
 merly
>> make sure we don't select the same route again and again.
>
>   rt6_multipath_select() -> rt6_socre_route() seems to require that t=
he
> interface *must* matchi, which is consistent with your assertion abov=
e that
> "ECMP routes differ in gw only".
In fact, ECMP routes have the same metric/weight and destination but no=
t the
same next hop (ie gw + oif).

>
> But for IPv6, the gw addr is a a link-local, which is only required t=
o be
> unique on the link. Thus, e.g.,  you can have fe80::1 as the gw on bo=
th eth0 and
> eth1.
Yes, oif can be different.
Note that gw can also be a global address.

>
> What is the assumption around "cost" for ECMP here- are we assuming s=
ome
> form of link bundling (Section 6 of rfc 2991) here? or is the "multip=
le parallel
> links" case handled somewhere else, that I am missing?
rt6_score_route() is called to check requested oif (see 52bd4c0c1551 "i=
pv6: fix=20
ecmp lookup when oif is specified").

Regards,
Nicolas

>
> --Sowmini
>
>>
>> Please note, the rt6_info's siblings fields were added for the solel=
y purpose
>> of ECMP and the insertion only updates the siblings list if the abov=
e criteria
>> did hold. They make sure the routes lookup up do differ on each look=
up, so it
>> does actually do multipath and does not depend on the order the rout=
es where
>> inserted.
>>
>> Hope that helps,
>>
>>    Hannes
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
