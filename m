From: Philippe Reynes <tremyfr@gmail.com>
Subject: Re: [PATCH 2/2] net: ethernet: bcmgenet: use phy_ethtool_{get|set}_link_ksettings
Date: Mon, 11 Jul 2016 00:50:08 +0200
Message-ID: <5782D120.9020605@gmail.com>
References: <1467560037-21784-1-git-send-email-tremyfr@gmail.com>  <1467560037-21784-2-git-send-email-tremyfr@gmail.com>  <20160704.160300.953705748553101659.davem@davemloft.net>  <577B37CC.80807@gmail.com> <577C2189.8090604@gmail.com>  <577C2380.4000007@gmail.com> <1467754810.4204.17.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35161 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757207AbcGJWuP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jul 2016 18:50:15 -0400
In-Reply-To: <1467754810.4204.17.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,


On 05/07/16 23:40, Ben Hutchings wrote:
> On Tue, 2016-07-05 at 14:15 -0700, Florian Fainelli wrote:
>> On 07/05/2016 02:07 PM, Philippe Reynes wrote:
>>> Hi Florian,
>>>
>>> On 05/07/16 06:30, Florian Fainelli wrote:
>>>> Le 04/07/2016 16:03, David Miller a =C3=A9crit :
>>>>> From: Philippe Reynes<tremyfr@gmail.com>
>>>>> Date: Sun,  3 Jul 2016 17:33:57 +0200
>>>>>
>>>>>> There are two generics functions phy_ethtool_{get|set}_link_kset=
tings,
>>>>>> so we can use them instead of defining the same code in the driv=
er.
>>>>>>
>>>>>> Signed-off-by: Philippe Reynes<tremyfr@gmail.com>
>>>>>
>>>>> Applied.
>>>>>
>>>>
>>>> The transformation is not equivalent, we lost the checks on
>>>> netif_running() in the process, and those are here for a reason, i=
f the
>>>> interface is down and therefore clock gated, MDIO accesses to the =
PHY
>>>> will simply fail outright and cause bus errors.
>>>
>>> Oh, I see, I've missed this. Sorry for this mistake.
>>> We should revert this path.
>>
>> Well, maybe better than that, actually put the check in the generic
>> functions, because if the link is down, aka netif_running() returns
>> false, link parameters cannot be reliably queried and they are inval=
id.

In my understanding, if the link is down, the pointer phydev in the
struct net_device is NULL. So generic functions phy_ethtool_{get|set}_l=
ink_ksetting
should return -ENODEV.

If I'm wrong, and it everybody agree, I'll send a patch that add a chec=
k
on netif_running.

> Either the hardware or the driver needs to remember:
>
> - Is auto-negotiation enabled
> - If so, which modes are advertised
> - If not, which mode is forced
>
> And it should still be possible to get or set that information when t=
he
> interface is down.

It could be possible to save the set_link_ksettings request if the link
is down, and apply it when the link become up.
It also could be possible to save the last state of the link before it
goes to down, and return it to a get_link_ksettings when the link is do=
wn.
But what happen if the link was never up before the first get_link_kett=
ings ?

If everybody agree with this, I may send a patch that implement this id=
ea.


Philippe
