From: Rick Jones <rick.jones2@hp.com>
Subject: Re: bonding with 3c59x driver
Date: Tue, 14 Feb 2012 10:27:05 -0800
Message-ID: <4F3AA779.3080409@hp.com>
References: <201202132253.16496.jdelvare@suse.de> <22039.1329171191@death.nxdomain> <201202141122.10705.jdelvare@suse.de> <20120214110604.GI32155@v3-1054> <1329218017.2336.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>,
	Jean Delvare <jdelvare@suse.de>,
	Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:15507 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756924Ab2BNS1H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2012 13:27:07 -0500
In-Reply-To: <1329218017.2336.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/14/2012 03:13 AM, Eric Dumazet wrote:
> Le mardi 14 f=C3=A9vrier 2012 =C3=A0 12:06 +0100, Steffen Klassert a =
=C3=A9crit :
>> On Tue, Feb 14, 2012 at 11:22:10AM +0100, Jean Delvare wrote:
>>>
>>> Well I am still curious why the 3c59x driver has such slow polling =
when
>>> other drivers I have been testing are able to report almost instant=
ly
>>> when I remove a network cable. Could it be that other network chips
>>> generate an interrupt on cable removal and the 3com chips do not?
>>>
>>
>> Yes, at least some of the supported chips do not generate an interru=
pt
>> on cable removal, so we have to check for this with a timer.
>> --
>
> We could have a 5 sec timer in case device is a slave.
>
> diff --git a/drivers/net/ethernet/3com/3c59x.c b/drivers/net/ethernet=
/3com/3c59x.c
> index 1282f04..e463d10 100644
> --- a/drivers/net/ethernet/3com/3c59x.c
> +++ b/drivers/net/ethernet/3com/3c59x.c
> @@ -1841,7 +1841,7 @@ vortex_timer(unsigned long data)
>   		ok =3D 1;
>   	}
>
> -	if (!netif_carrier_ok(dev))
> +	if (dev->flags&  IFF_SLAVE || !netif_carrier_ok(dev))
>   		next_tick =3D 5*HZ;
>
>   	if (vp->medialock)

Does the device being a slave in a bond change the overheads of the=20
check being performed?

rick jones
