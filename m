From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net v2] ip6_tunnel: fix error code when tunnel exists
Date: Tue, 17 Mar 2015 09:27:28 +0100
Message-ID: <5507E570.9050602@6wind.com>
References: <20150313.123231.1641333637059823788.davem@davemloft.net>	<1426517765-4649-1-git-send-email-nicolas.dichtel@6wind.com> <20150316.163413.1468551206666732117.davem@davemloft.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, me@pierre-cheynier.net,
	eric.dumazet@gmail.com, steffen.klassert@secunet.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:34806 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751268AbbCQI1b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 04:27:31 -0400
Received: by wibg7 with SMTP id g7so42887368wib.1
        for <netdev@vger.kernel.org>; Tue, 17 Mar 2015 01:27:30 -0700 (PDT)
In-Reply-To: <20150316.163413.1468551206666732117.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 16/03/2015 21:34, David Miller a =E9crit :
> From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Date: Mon, 16 Mar 2015 15:56:05 +0100
>
>> @@ -1445,7 +1445,7 @@ ip6_tnl_ioctl(struct net_device *dev, struct i=
freq *ifr, int cmd)
>>   		ip6_tnl_parm_from_user(&p1, &p);
>>   		t =3D ip6_tnl_locate(net, &p1, cmd =3D=3D SIOCADDTUNNEL);
>>   		if (cmd =3D=3D SIOCCHGTUNNEL) {
>> -			if (t !=3D NULL) {
>> +			if (!IS_ERR(t)) {
>>   				if (t->dev !=3D dev) {
>>   					err =3D -EEXIST;
>>   					break;
>
> Please convert that last assignment to "err =3D PTR_ERR(t);", thanks.
It's not possible, the if() statement checks that 't' is *not* an error=
=2E
And in this case, we report to the user that the tunnel already exists.
