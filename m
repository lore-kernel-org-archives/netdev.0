From: "Pradeep A. Dalvi" <netdev@pradeepdalvi.com>
Subject: Re: [PATCH/RESEND net 5/5][NON-TRIVIAL] drivers/net/ethernet:
 dev_alloc_skb to netdev_alloc_skb
Date: Tue, 24 Jan 2012 03:00:12 +0530
Message-ID: <CA+Dx6HZK2ns94pG79FfPZpVO9+QY8LQ00zFyeK5zZjc6HLq-cQ@mail.gmail.com>
References: <1327352046-6896-1-git-send-email-netdev@pradeepdalvi.com>
	<1327352667.2587.4.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, Christoph Hellwig <hch@lst.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1327352667.2587.4.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 24, 2012 at 2:34 AM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le mardi 24 janvier 2012 =E0 02:24 +0530, Pradeep A. Dalvi a =E9crit =
:
>> Replaced deprecating dev_alloc_skb with netdev_alloc_skb in drivers/=
net/ethernet
>> =A0 - Removed extra skb->dev =3D dev after netdev_alloc_skb
>>
>
>
>>
>> =A0/* Initialize the LANCE Rx and Tx rings. */
>> =A0static void
>> -lance_init_ring(struct net_device *dev, gfp_t gfp)
>> +lance_init_ring(struct net_device *dev)
>> =A0{
>> =A0 =A0 =A0 struct lance_private *lp =3D dev->ml_priv;
>> =A0 =A0 =A0 int i;
>> @@ -871,13 +871,12 @@ lance_init_ring(struct net_device *dev, gfp_t =
gfp)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct sk_buff *skb;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 void *rx_buff;
>>
>> - =A0 =A0 =A0 =A0 =A0 =A0 skb =3D alloc_skb(PKT_BUF_SZ, GFP_DMA | gf=
p);
>> + =A0 =A0 =A0 =A0 =A0 =A0 skb =3D netdev_alloc_skb(dev, PKT_BUF_SZ);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 lp->rx_skbuff[i] =3D skb;
>> - =A0 =A0 =A0 =A0 =A0 =A0 if (skb) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb->dev =3D dev;
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (skb)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rx_buff =3D skb->data;
>> - =A0 =A0 =A0 =A0 =A0 =A0 } else
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rx_buff =3D kmalloc(PKT_BU=
=46_SZ, GFP_DMA | gfp);
>> + =A0 =A0 =A0 =A0 =A0 =A0 else
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rx_buff =3D kmalloc(PKT_BU=
=46_SZ, GFP_DMA | GFP_AUTOMIC);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (rx_buff =3D=3D NULL)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 lp->rx_ring[i].base =3D =
0;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
>
> Thats really crap, please dont send us such patches, not even compile=
d.
>
> alloc_skb() has nothing to do with dev_alloc_skb(), and there is a
> reason GFP_DMA is used in this driver.

Would drop these changes and resubmit the patch. Thanks!
