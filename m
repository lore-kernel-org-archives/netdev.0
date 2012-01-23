From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH/RESEND net 5/5][NON-TRIVIAL] drivers/net/ethernet:
 dev_alloc_skb to netdev_alloc_skb
Date: Mon, 23 Jan 2012 16:55:30 -0500 (EST)
Message-ID: <20120123.165530.944969261195932179.davem@davemloft.net>
References: <1327352046-6896-1-git-send-email-netdev@pradeepdalvi.com>
	<1327352667.2587.4.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@pradeepdalvi.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, hch@lst.de
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58968 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753444Ab2AWVzi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2012 16:55:38 -0500
In-Reply-To: <1327352667.2587.4.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 23 Jan 2012 22:04:27 +0100

> Le mardi 24 janvier 2012 =E0 02:24 +0530, Pradeep A. Dalvi a =E9crit =
:
>> Replaced deprecating dev_alloc_skb with netdev_alloc_skb in drivers/=
net/ethernet
>>   - Removed extra skb->dev =3D dev after netdev_alloc_skb
>>=20
>=20
>=20
>> =20
>>  /* Initialize the LANCE Rx and Tx rings. */
>>  static void
>> -lance_init_ring(struct net_device *dev, gfp_t gfp)
>> +lance_init_ring(struct net_device *dev)
>>  {
>>  	struct lance_private *lp =3D dev->ml_priv;
>>  	int i;
>> @@ -871,13 +871,12 @@ lance_init_ring(struct net_device *dev, gfp_t =
gfp)
>>  		struct sk_buff *skb;
>>  		void *rx_buff;
>> =20
>> -		skb =3D alloc_skb(PKT_BUF_SZ, GFP_DMA | gfp);
>> +		skb =3D netdev_alloc_skb(dev, PKT_BUF_SZ);
>>  		lp->rx_skbuff[i] =3D skb;
>> -		if (skb) {
>> -			skb->dev =3D dev;
>> +		if (skb)
>>  			rx_buff =3D skb->data;
>> -		} else
>> -			rx_buff =3D kmalloc(PKT_BUF_SZ, GFP_DMA | gfp);
>> +		else
>> +			rx_buff =3D kmalloc(PKT_BUF_SZ, GFP_DMA | GFP_AUTOMIC);
>>  		if (rx_buff =3D=3D NULL)
>>  			lp->rx_ring[i].base =3D 0;
>>  		else
>=20
> Thats really crap, please dont send us such patches, not even compile=
d.
>=20
> alloc_skb() has nothing to do with dev_alloc_skb(), and there is a
> reason GFP_DMA is used in this driver.

This is really terrible.

Pradeep please stop sending these changes until you have your house
in order.  Your patches are buggy and ill conceived.

Please do not submit more patches in this area until you spend the
necessary time to truly understand these interfaces and how these code
snippets actually work.
