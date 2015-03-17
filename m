From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net v2] ip6_tunnel: fix error code when tunnel exists
Date: Tue, 17 Mar 2015 15:02:01 -0400 (EDT)
Message-ID: <20150317.150201.1177761498452343682.davem@redhat.com>
References: <1426517765-4649-1-git-send-email-nicolas.dichtel@6wind.com>
	<20150316.163413.1468551206666732117.davem@davemloft.net>
	<5507E570.9050602@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, me@pierre-cheynier.net,
	eric.dumazet@gmail.com, steffen.klassert@secunet.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36574 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753764AbbCQTCO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 15:02:14 -0400
In-Reply-To: <5507E570.9050602@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Tue, 17 Mar 2015 09:27:28 +0100

> Le 16/03/2015 21:34, David Miller a =E9crit :
>> From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>> Date: Mon, 16 Mar 2015 15:56:05 +0100
>>
>>> @@ -1445,7 +1445,7 @@ ip6_tnl_ioctl(struct net_device *dev, struct
>>> ifreq *ifr, int cmd)
>>>   		ip6_tnl_parm_from_user(&p1, &p);
>>>   		t =3D ip6_tnl_locate(net, &p1, cmd =3D=3D SIOCADDTUNNEL);
>>>   		if (cmd =3D=3D SIOCCHGTUNNEL) {
>>> -			if (t !=3D NULL) {
>>> +			if (!IS_ERR(t)) {
>>>   				if (t->dev !=3D dev) {
>>>   					err =3D -EEXIST;
>>>   					break;
>>
>> Please convert that last assignment to "err =3D PTR_ERR(t);", thanks=
=2E
> It's not possible, the if() statement checks that 't' is *not* an
> error.
> And in this case, we report to the user that the tunnel already
> exists.

My bad, thanks for explaining.

Applied.
