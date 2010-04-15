From: David Miller <davem@davemloft.net>
Subject: Re: NULL pointer dereference panic in stable (2.6.33.2), amd64
Date: Thu, 15 Apr 2010 14:33:21 -0700 (PDT)
Message-ID: <20100415.143321.200497785.davem@davemloft.net>
References: <20100415.020619.00349859.davem@davemloft.net>
	<1271363432.16881.3080.camel@edumazet-laptop>
	<1271364375.16881.3099.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: krkumar2@in.ibm.com, netdev@vger.kernel.org,
	nuclearcat@nuclearcat.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50558
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757230Ab0DOVdR convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Apr 2010 17:33:17 -0400
In-Reply-To: <1271364375.16881.3099.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 15 Apr 2010 22:46:15 +0200

> Le jeudi 15 avril 2010 =E0 22:30 +0200, Eric Dumazet a =E9crit :
>> =20
>> @@ -1938,6 +1928,8 @@ gso:
>>  		if (dev->priv_flags & IFF_XMIT_DST_RELEASE)
>>  			skb_dst_drop(nskb);
>> =20
>> +		skb_orphan(nskb);
>> +
>>  		rc =3D ops->ndo_start_xmit(nskb, dev);
>>  		if (unlikely(rc !=3D NETDEV_TX_OK)) {
>>  			if (rc & ~NETDEV_TX_MASK)
>=20
> Well, might need to test if skb is not shared before orphaning it
>=20
> 	if (!skb_shared(skb))
> 		skb_orphan(nskb);

If it's not legal to skb_orphan() here then it would not be legal for
the drivers to unconditionally skb_orphan(), which they do.

So either your test is unnecessary, or we have a big existing problem
:-)

