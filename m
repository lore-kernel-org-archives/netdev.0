From: "Pradeep A. Dalvi" <netdev@pradeepdalvi.com>
Subject: Re: [PATCH] netdev/ethernet: dev_alloc_skb to netdev_alloc_skb
Date: Mon, 23 Jan 2012 16:07:36 +0530
Message-ID: <CA+Dx6HbqAhjS6TNy=t+jvrwrmpTuQ3c=Wq0UnMzFRr9Q+JKpKQ@mail.gmail.com>
References: <1327179463-13980-1-git-send-email-netdev@pradeepdalvi.com>
	<1327311925.2525.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Christoph Hellwig <hch@lst.de>, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1327311925.2525.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 23, 2012 at 3:15 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le dimanche 22 janvier 2012 =E0 02:27 +0530, Pradeep A. Dalvi a =E9cr=
it :
>> Replaced deprecating dev_alloc_skb with netdev_alloc_skb in drivers/=
net/ethernet
>>
>
> ...
>
>
>> diff --git a/drivers/net/ethernet/3com/3c515.c b/drivers/net/etherne=
t/3com/3c515.c
>> index f67a5d3..68fd765 100644
>> --- a/drivers/net/ethernet/3com/3c515.c
>> +++ b/drivers/net/ethernet/3com/3c515.c
>> @@ -826,7 +826,7 @@ static int corkscrew_open(struct net_device *dev=
)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vp->rx_r=
ing[i].next =3D 0;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vp->rx_ring[i].status =3D=
 0; =A0 =A0 =A0/* Clear complete bit. */
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vp->rx_ring[i].length =3D=
 PKT_BUF_SZ | 0x80000000;
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb =3D dev_alloc_skb(PKT_=
BUF_SZ);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb =3D netdev_alloc_skb(d=
ev, PKT_BUF_SZ);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vp->rx_skbuff[i] =3D skb=
;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (skb =3D=3D NULL)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break; =A0=
/* Bad news! =A0*/
>
>
> One of the difference between netdev_alloc_skb() and dev_alloc_skb() =
is
> the former initializes skb->dev.
>
> So you should remove the extra "skb->dev =3D dev;" lines that sometim=
es
> are after the dev_alloc_skb() calls.
>
> [ They were redundant anyway because eth_type_trans() also sets skb->=
dev
> ]

Thanks! Shall take extra skb->dev =3D dev into consideration.

Eric, is this ok to assume that the memory address given to
dma_map_single & received from dma_unmap_single would remain same
across all platforms? Thanks in advance!
