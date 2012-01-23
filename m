From: "Pradeep A. Dalvi" <netdev@pradeepdalvi.com>
Subject: Re: [PATCH/RESEND net 5/5][NON-TRIVIAL] drivers/net/ethernet:
 dev_alloc_skb to netdev_alloc_skb
Date: Tue, 24 Jan 2012 03:52:17 +0530
Message-ID: <CA+Dx6HbgoSgeLFCarF5MAh_z5psWyLEb9UVbhKXCjmxm4OsA8w@mail.gmail.com>
References: <1327352046-6896-1-git-send-email-netdev@pradeepdalvi.com>
	<1327352667.2587.4.camel@edumazet-laptop>
	<20120123.165530.944969261195932179.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, hch@lst.de
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120123.165530.944969261195932179.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 24, 2012 at 3:25 AM, David Miller <davem@davemloft.net> wro=
te:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 23 Jan 2012 22:04:27 +0100
>
>> Le mardi 24 janvier 2012 =E0 02:24 +0530, Pradeep A. Dalvi a =E9crit=
 :
>>> Replaced deprecating dev_alloc_skb with netdev_alloc_skb in drivers=
/net/ethernet
>>> =A0 - Removed extra skb->dev =3D dev after netdev_alloc_skb
>>>
>>
>>
>>>
>>> =A0/* Initialize the LANCE Rx and Tx rings. */
>>> =A0static void
>>> -lance_init_ring(struct net_device *dev, gfp_t gfp)
>>> +lance_init_ring(struct net_device *dev)
>>> =A0{
>>> =A0 =A0 =A0struct lance_private *lp =3D dev->ml_priv;
>>> =A0 =A0 =A0int i;
>>> @@ -871,13 +871,12 @@ lance_init_ring(struct net_device *dev, gfp_t=
 gfp)
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0struct sk_buff *skb;
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0void *rx_buff;
>>>
>>> - =A0 =A0 =A0 =A0 =A0 =A0skb =3D alloc_skb(PKT_BUF_SZ, GFP_DMA | gf=
p);
>>> + =A0 =A0 =A0 =A0 =A0 =A0skb =3D netdev_alloc_skb(dev, PKT_BUF_SZ);
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0lp->rx_skbuff[i] =3D skb;
>>> - =A0 =A0 =A0 =A0 =A0 =A0if (skb) {
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0skb->dev =3D dev;
>>> + =A0 =A0 =A0 =A0 =A0 =A0if (skb)
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rx_buff =3D skb->data;
>>> - =A0 =A0 =A0 =A0 =A0 =A0} else
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rx_buff =3D kmalloc(PKT_BU=
=46_SZ, GFP_DMA | gfp);
>>> + =A0 =A0 =A0 =A0 =A0 =A0else
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rx_buff =3D kmalloc(PKT_BU=
=46_SZ, GFP_DMA | GFP_AUTOMIC);
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0if (rx_buff =3D=3D NULL)
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0lp->rx_ring[i].base =3D =
0;
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0else
>>
>> Thats really crap, please dont send us such patches, not even compil=
ed.
>>
>> alloc_skb() has nothing to do with dev_alloc_skb(), and there is a
>> reason GFP_DMA is used in this driver.
>
> This is really terrible.
>
> Pradeep please stop sending these changes until you have your house
> in order. =A0Your patches are buggy and ill conceived.
>
> Please do not submit more patches in this area until you spend the
> necessary time to truly understand these interfaces and how these cod=
e
> snippets actually work.

Thanks for inputs!

Have submitted changes in total 118 files, and out of which changes in
this 1 single file is outcome of final minute changes. Apologies for
that!

Although, there are 4 other patches with trivial changes in total 114
files. You may want to consider them and probably want to discard
final i.e. 5th of 5 completely.

Anyways, have already resubmitted all patches again, reverting changes
pointed in here & correcting 5th patch.
