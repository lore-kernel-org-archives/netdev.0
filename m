From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH -next] sundance: Add initial ethtool stats support
Date: Wed, 13 Oct 2010 08:33:57 +0200
Message-ID: <1286951637.2703.141.camel@edumazet-laptop>
References: <20101009095346.GA12951@hera.kernel.org>
	 <20101009132749.GA15074@solarflare.com>	<4CB0C56C.2000106@kernel.org>
	 <20101012.115138.112614145.davem@davemloft.net>
	 <4CB4C6E6.9090805@kernel.org> <1286917039.1117.101.camel@Joe-Laptop>
	 <4CB54C4F.5070205@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Joe Perches <joe@perches.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Jeff Garzik <jgarzik@redhat.com>
To: Denis Kirjanov <dkirjanov@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:53660 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752641Ab0JMGeT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Oct 2010 02:34:19 -0400
Received: by wyb28 with SMTP id 28so734005wyb.19
        for <netdev@vger.kernel.org>; Tue, 12 Oct 2010 23:34:18 -0700 (PDT)
In-Reply-To: <4CB54C4F.5070205@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 13 octobre 2010 =C3=A0 10:06 +0400, Denis Kirjanov a =C3=A9=
crit :

> @@ -1494,13 +1506,23 @@ static struct net_device_stats *get_stats(str=
uct net_device *dev)
>  	dev->stats.rx_missed_errors	+=3D ioread8(ioaddr + RxMissed);
>  	dev->stats.tx_packets +=3D ioread16(ioaddr + TxFramesOK);
>  	dev->stats.rx_packets +=3D ioread16(ioaddr + RxFramesOK);
> -	dev->stats.collisions +=3D ioread8(ioaddr + StatsLateColl);
> -	dev->stats.collisions +=3D ioread8(ioaddr + StatsMultiColl);
> -	dev->stats.collisions +=3D ioread8(ioaddr + StatsOneColl);
>  	dev->stats.tx_carrier_errors +=3D ioread8(ioaddr + StatsCarrierErro=
r);
> -	ioread8(ioaddr + StatsTxDefer);
> -	for (i =3D StatsTxDefer; i <=3D StatsMcastRx; i++)
> -		ioread8(ioaddr + i);
> +
> +	np->xstats.tx_multiple_collisions +=3D ioread8(ioaddr + StatsMultiC=
oll);
> +	np->xstats.tx_single_collisions +=3D ioread8(ioaddr + StatsOneColl)=
;
> +	np->xstats.tx_late_collisions +=3D ioread8(ioaddr + StatsLateColl);
> +	dev->stats.collisions +=3D np->xstats.tx_multiple_collisions
> +		+ np->xstats.tx_single_collisions
> +		+ np->xstats.tx_late_collisions;


Oh well..., really ?

Each time we are calling get_stats(), you do

dev->stats.collisions +=3D (number of accumulated collisions since devi=
ce
is up)

instead of

dev->stats.collisions +=3D (number of accumulated collisions since last
time we read counters)


Can you see the problem ?



