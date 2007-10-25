From: Patrick McHardy <kaber@trash.net>
Subject: Re: [IFGROUPv4 2/3] Interface group: core (netlink) part
Date: Thu, 25 Oct 2007 17:40:57 +0200
Message-ID: <4720B909.7000108@trash.net>
References: <11933245923082-git-send-email-panther@balabit.hu> <11933245922165-git-send-email-panther@balabit.hu> <11933245921874-git-send-email-panther@balabit.hu> <4720B2E6.1060505@trash.net> <4720B6D4.8080404@balabit.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: panther@balabit.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:44921 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755467AbXJYPmd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2007 11:42:33 -0400
In-Reply-To: <4720B6D4.8080404@balabit.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Laszlo Attila Toth wrote:
> Patrick McHardy =EDrta:
>> Laszlo Attila Toth wrote:
>>> Interface groups let handle different interfaces together
>>> especially in netfilter modules.
>>> Modified net device structure and netlink interface.
>>>
>>> @@ -891,6 +895,13 @@ static int do_setlink(struct net_device *dev,=20
>>> struct ifinfomsg *ifm,
>>>          }
>>>      }
>>> =20
>>> +    if (tb[IFLA_IFGROUP]) {
>>> +        write_lock_bh(&dev_base_lock);
>>> +        dev->ifgroup =3D nla_get_u32(tb[IFLA_IFGROUP]);
>>> +        write_unlock_bh(&dev_base_lock);
>>> +        modified =3D 1;
>>> +    }
>>
>>
>> The locking looks unnecessary, the rtnl should be enough.
>> I'm not even sure why its used for operstate and linkmode,
>> AFAICS they are also protected by the rtnl.
>>
>=20
> Hm, ok. In this case operstate and linkmode can be unprotected as cod=
e=20
> cleanup, am I right? Or leave them unchanged?


There seems to be a single case where operstate is used without
the rtnl (under dev_base_lock), in dev_get_flags() invoked by
dev_ifsioc_locked(). But that looks like a bug, there are many
callers of dev_change_flags() that only take the rtnl. So this
would be more a fix than a cleanup.

> And notification is only needed if something was changed.

Yes.
