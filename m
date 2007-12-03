From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCHv7 2/5] rtnetlink: send a single notification on device state changes
Date: Mon, 3 Dec 2007 14:37:39 +0100
Message-ID: <20071203133739.GA3909@ff.dom.local>
References: <4753EB22.5040603@balabit.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: panther@balabit.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.go2.pl ([193.17.41.42]:56432 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751738AbXLCNcx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Dec 2007 08:32:53 -0500
Content-Disposition: inline
In-Reply-To: <4753EB22.5040603@balabit.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03-12-2007 12:40, Laszlo Attila Toth wrote:
> Jarek Poplawski =EDrta:
>> Laszlo Attila Toth wrote, On 11/29/2007 05:11 PM:
>>
>>> In do_setlink() a single ntification is sent at the end of the func=
tion
>>> if any modification occured. If the address has been changed, anoth=
er
>>> notification is sent.
>>
>>
>> ...
>>
>>> @@ -858,6 +859,7 @@ static int do_setlink(struct net_device *dev,=20
>>> struct ifinfomsg *ifm,
>>>      if (tb[IFLA_BROADCAST]) {
>>>          nla_memcpy(dev->broadcast, tb[IFLA_BROADCAST], dev->addr_l=
en);
>>>          send_addr_notify =3D 1;
>>> +        modified =3D 1;
>>>      }
>>
>> ..
>>
>>>      if (send_addr_notify)
>>>          call_netdevice_notifiers(NETDEV_CHANGEADDR, dev);
>>> +
>>> +    if (modified)
>>> +        netdev_state_change(dev);
>>> +
>>
>> The subject suggests there might be less notifications. The patch=20
>> actually
>> adds a little. Any additional comment why they are necessary?
>=20
> The actual state of a device contains its address(es), also address=20
> change implies state change, but these are different netlink messages=
=20
> also the NETDEV_CHANGEADDR cannot be dropped because the other one is=
 used.

OK. But, since until this patch it seemed to be enough, it would be
nice to know from the changelog why exactly it's nececessary to add
this now, because it doesn't look like it was omitted here by mistake.
(Or to say that it was omitted by mistake.)

Regards,
Jarek P.
