From: Denis Kirjanov <dkirjanov@kernel.org>
Subject: Re: [PATCH -next] sundance: Add initial ethtool stats support
Date: Wed, 13 Oct 2010 11:02:13 +0400
Message-ID: <4CB55975.4080109@kernel.org>
References: <20101009095346.GA12951@hera.kernel.org>	 <20101009132749.GA15074@solarflare.com>	<4CB0C56C.2000106@kernel.org>	 <20101012.115138.112614145.davem@davemloft.net>	 <4CB4C6E6.9090805@kernel.org> <1286917039.1117.101.camel@Joe-Laptop>	 <4CB54C4F.5070205@kernel.org> <1286951637.2703.141.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Joe Perches <joe@perches.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Jeff Garzik <jgarzik@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:54942 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752858Ab0JMHC2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Oct 2010 03:02:28 -0400
In-Reply-To: <1286951637.2703.141.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/13/2010 10:33 AM, Eric Dumazet wrote:
> Le mercredi 13 octobre 2010 =C3=A0 10:06 +0400, Denis Kirjanov a =C3=A9=
crit :
>=20
>> @@ -1494,13 +1506,23 @@ static struct net_device_stats *get_stats(st=
ruct net_device *dev)
>>  	dev->stats.rx_missed_errors	+=3D ioread8(ioaddr + RxMissed);
>>  	dev->stats.tx_packets +=3D ioread16(ioaddr + TxFramesOK);
>>  	dev->stats.rx_packets +=3D ioread16(ioaddr + RxFramesOK);
>> -	dev->stats.collisions +=3D ioread8(ioaddr + StatsLateColl);
>> -	dev->stats.collisions +=3D ioread8(ioaddr + StatsMultiColl);
>> -	dev->stats.collisions +=3D ioread8(ioaddr + StatsOneColl);
>>  	dev->stats.tx_carrier_errors +=3D ioread8(ioaddr + StatsCarrierErr=
or);
>> -	ioread8(ioaddr + StatsTxDefer);
>> -	for (i =3D StatsTxDefer; i <=3D StatsMcastRx; i++)
>> -		ioread8(ioaddr + i);
>> +
>> +	np->xstats.tx_multiple_collisions +=3D ioread8(ioaddr + StatsMulti=
Coll);
>> +	np->xstats.tx_single_collisions +=3D ioread8(ioaddr + StatsOneColl=
);
>> +	np->xstats.tx_late_collisions +=3D ioread8(ioaddr + StatsLateColl)=
;
>> +	dev->stats.collisions +=3D np->xstats.tx_multiple_collisions
>> +		+ np->xstats.tx_single_collisions
>> +		+ np->xstats.tx_late_collisions;
>=20
>=20
> Oh well..., really ?
>=20
> Each time we are calling get_stats(), you do
>=20
> dev->stats.collisions +=3D (number of accumulated collisions since de=
vice
> is up)
>=20
> instead of
>=20
> dev->stats.collisions +=3D (number of accumulated collisions since la=
st
> time we read counters)
>=20
>=20
> Can you see the problem ?

Oops, thanks Eric!
I'll fix it up and resend
>=20
>=20

