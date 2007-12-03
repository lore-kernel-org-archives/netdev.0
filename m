From: Laszlo Attila Toth <panther@balabit.hu>
Subject: Re: [PATCHv7 2/5] rtnetlink: send a single notification on device
 state changes
Date: Mon, 03 Dec 2007 12:40:18 +0100
Message-ID: <4753EB22.5040603@balabit.hu>
References: <11963527094077-git-send-email-panther@balabit.hu> <11963527103201-git-send-email-panther@balabit.hu> <1196352710402-git-send-email-panther@balabit.hu> <47509BB9.10108@o2.pl>
Reply-To: panther@balabit.hu
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.balabit.hu ([212.92.18.33]:51968 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751629AbXLCLkV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Dec 2007 06:40:21 -0500
Received: from balabit.hu (unknown [10.80.0.254])
	by lists.balabit.hu (Postfix) with ESMTP id 385EEC12F1
	for <netdev@vger.kernel.org>; Mon,  3 Dec 2007 12:40:20 +0100 (CET)
In-Reply-To: <47509BB9.10108@o2.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski =EDrta:
> Laszlo Attila Toth wrote, On 11/29/2007 05:11 PM:
>=20
>> In do_setlink() a single ntification is sent at the end of the funct=
ion
>> if any modification occured. If the address has been changed, anothe=
r
>> notification is sent.
>=20
>=20
> ...
>=20
>> @@ -858,6 +859,7 @@ static int do_setlink(struct net_device *dev, st=
ruct ifinfomsg *ifm,
>>  	if (tb[IFLA_BROADCAST]) {
>>  		nla_memcpy(dev->broadcast, tb[IFLA_BROADCAST], dev->addr_len);
>>  		send_addr_notify =3D 1;
>> +		modified =3D 1;
>>  	}
>=20
> ..
>=20
>>  	if (send_addr_notify)
>>  		call_netdevice_notifiers(NETDEV_CHANGEADDR, dev);
>> +
>> +	if (modified)
>> +		netdev_state_change(dev);
>> +
>=20
> The subject suggests there might be less notifications. The patch act=
ually
> adds a little. Any additional comment why they are necessary?

The actual state of a device contains its address(es), also address=20
change implies state change, but these are different netlink messages=20
also the NETDEV_CHANGEADDR cannot be dropped because the other one is u=
sed.

Attila
