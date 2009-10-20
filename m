From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Fix IP_MULTICAST_IF
Date: Tue, 20 Oct 2009 06:23:54 +0200
Message-ID: <4ADD3B5A.1080905@gmail.com>
References: <4ADC96D6.4000909@gmail.com>	<20091019.205948.193706797.davem@davemloft.net>	<4ADD3794.8030906@gmail.com> <20091019.212018.79580287.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:33642 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750739AbZJTEXw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2009 00:23:52 -0400
In-Reply-To: <20091019.212018.79580287.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 20 Oct 2009 06:07:48 +0200
>=20
>> Final target might be fine, but an element in the chain, before targ=
et
>> could be deleted while reader scans hash chain.
>  ...
>> So it should visit a nice memory location ?
>=20
> It should hit a NULL eventually and deterministically even if an
> unlink happens at the same time..... unless the object gets free'd
> meanwhile, hmmm...
>=20
> This code is definitely intentional, I remember when I added it to
> the tree, Alexey wrote it :-)

I wonder if the whole thing could use RCU somehow, since some workloads=
 hit
this dev_base_lock rwlock pretty hard...

