From: Laszlo Attila Toth <panther@balabit.hu>
Subject: Re: [IFGROUPv4 2/3] Interface group: core (netlink) part
Date: Thu, 25 Oct 2007 17:31:32 +0200
Message-ID: <4720B6D4.8080404@balabit.hu>
References: <11933245923082-git-send-email-panther@balabit.hu> <11933245922165-git-send-email-panther@balabit.hu> <11933245921874-git-send-email-panther@balabit.hu> <4720B2E6.1060505@trash.net>
Reply-To: panther@balabit.hu
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.balabit.hu ([212.92.18.33]:36494 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758265AbXJYPbh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Oct 2007 11:31:37 -0400
Received: from balabit.hu (unknown [10.80.0.254])
	by lists.balabit.hu (Postfix) with ESMTP id A7ADFC1301
	for <netdev@vger.kernel.org>; Thu, 25 Oct 2007 17:31:36 +0200 (CEST)
In-Reply-To: <4720B2E6.1060505@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy =EDrta:
> Laszlo Attila Toth wrote:
>> Interface groups let handle different interfaces together
>> especially in netfilter modules.
>> Modified net device structure and netlink interface.
>>
>> @@ -891,6 +895,13 @@ static int do_setlink(struct net_device *dev,=20
>> struct ifinfomsg *ifm,
>>          }
>>      }
>> =20
>> +    if (tb[IFLA_IFGROUP]) {
>> +        write_lock_bh(&dev_base_lock);
>> +        dev->ifgroup =3D nla_get_u32(tb[IFLA_IFGROUP]);
>> +        write_unlock_bh(&dev_base_lock);
>> +        modified =3D 1;
>> +    }
>=20
>=20
> The locking looks unnecessary, the rtnl should be enough.
> I'm not even sure why its used for operstate and linkmode,
> AFAICS they are also protected by the rtnl.
>=20

Hm, ok. In this case operstate and linkmode can be unprotected as code=20
cleanup, am I right? Or leave them unchanged?
And notification is only needed if something was changed.

--
Attila
