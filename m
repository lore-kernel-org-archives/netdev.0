From: Andrey Volkov <andrey.volkov@nexvision.fr>
Subject: Re: [PATCH RFC 1/2] net: dsa: integrate with SWITCHDEV for HW bridging
Date: Fri, 27 Feb 2015 18:09:50 +0100
Message-ID: <54F0A4DE.3020704@nexvision.fr>
References: <54EA8E7C.90401@roeck-us.net> <20150223031447.GA19267@lunn.ch> <54EAA767.6060105@roeck-us.net> <20150223042220.GA20063@lunn.ch> <54EAAEBC.6080609@roeck-us.net> <CAGVrzcYnuV6raXSrAETctwX5dwX3S=2-=ySewCFdx=iM7bPaDg@mail.gmail.com> <20150223133454.GB23581@lunn.ch> <54EB37C7.3090209@roeck-us.net> <20150223160109.GB27057@lunn.ch> <54EB6BF5.2020600@gmail.com> <20150223183537.GA23456@roeck-us.net> <54EDD172.4010606@nexvision.fr> <54EDDB72.1090706@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Lunn <andrew@lunn.ch>, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	jerome.oufella@savoirfairelinux.com,
	Chris Healy <cphealy@gmail.com>
To: Guenter Roeck <linux@roeck-us.net>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 2.mo5.mail-out.ovh.net ([178.33.109.111]:37404 "EHLO
	2.mo5.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755681AbbB0XJg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 18:09:36 -0500
Received: from mail414.ha.ovh.net (b6.ovh.net [213.186.33.56])
	by mo5.mail-out.ovh.net (Postfix) with SMTP id 613EDFF9244
	for <netdev@vger.kernel.org>; Fri, 27 Feb 2015 18:09:53 +0100 (CET)
In-Reply-To: <54EDDB72.1090706@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gunter,

Sorry with response delay, I very was busy yesterday

Le 25/02/2015 15:25, Guenter Roeck a =E9crit :
> Andrey,

------- snip -------=20

>>>
>> I simply modify port's fid to the new one in the leave routine and s=
et to common bridge FID in enter
>> (I'm using Marvell's chips). So the port's database will cleaned up =
automatically for the leave and will
>> contain something useful at the enter time. Also I've look through y=
ours patches and I haven't
>=20
> Does removing a port from a fid clean up the entries associated with =
it
> in the database ?

I've checked what happened when port changed its FID: switch logic bloc=
k traffic to it
immediately, as far as I can see, meanwhile record still exists in the =
bridge database,
it was checked on 88e6185, 88e6097 and 88e6352 chips. And yet another 5=
c: changing of group membership is
not atomic operation in the Marvell's chips known for me, so the port m=
ust be in the disabled state when it=20
will happened.

>=20
>> seen any mutichip bridges/hardwared "trunks" support (in the Marvell=
's sense), did anyone, except me, use it?
>>
> Not me. That would be difficult to test without real hardware.
>=20
> The above suggests that you have a HW bridge implementation for Marve=
ll chips as well.
> Would it make sense to merge our implementations, or just use yours i=
f it is better ?
>=20
>> Btw your current FID implementation contain funny security problem: =
same ports in the different chips,
>> interconnected by DSA, will have same FID and as result they will tr=
eated as bridged together by
>> internal switch logic...
>>
> You mean if multiple switch chips are used ? Those ports are configur=
ed to only send
> data to the CPU port. Doesn't that take care of the problem ? Granted=
, I have not
> looked into multi-chip applications, so there may well be some proble=
ms. Maybe
> it is possible to merge a chip ID into the fid to solve it.
>=20
> Thanks,
> Guenter
>=20

Regards,
Andrey
