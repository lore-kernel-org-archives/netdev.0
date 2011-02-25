From: Po-Yu Chuang <ratbert.chuang@gmail.com>
Subject: Re: [PATCH ref0] net: add Faraday FTMAC100 10/100 Ethernet driver
Date: Fri, 25 Feb 2011 17:45:40 +0800
Message-ID: <AANLkTikmqQfT1s2Z6J+KYmqi0CuCc4+2k67eeb4ydtCM@mail.gmail.com>
References: <1298535761.2814.1.camel@edumazet-laptop> <1298539762-2242-1-git-send-email-ratbert.chuang@gmail.com>
 <1298569179.2814.11.camel@edumazet-laptop> <1298569685.2814.16.camel@edumazet-laptop>
 <AANLkTikXUyQy+fjFSwagB3Uud2JPodsR2yFtt+jiZPSk@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	bhutchings@solarflare.com, joe@perches.com, dilinger@queued.net,
	mirqus@gmail.com, davem@davemloft.net,
	Po-Yu Chuang <ratbert@faraday-tech.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTikXUyQy+fjFSwagB3Uud2JPodsR2yFtt+jiZPSk@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Eric,

On Fri, Feb 25, 2011 at 10:32 AM, Po-Yu Chuang <ratbert.chuang@gmail.co=
m> wrote:
> On Fri, Feb 25, 2011 at 1:48 AM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:
>> Le jeudi 24 f=C3=A9vrier 2011 =C3=A0 18:39 +0100, Eric Dumazet a =C3=
=A9crit :
>>> Le jeudi 24 f=C3=A9vrier 2011 =C3=A0 17:29 +0800, Po-Yu Chuang a =C3=
=A9crit :
>>> > From: Po-Yu Chuang <ratbert@faraday-tech.com>
>>> > +
>>> > +static bool ftmac100_rx_packet(struct ftmac100 *priv, int *proce=
ssed)
>>> > +{
>>> > + =C2=A0 struct net_device *netdev =3D priv->netdev;
>>> > + =C2=A0 struct ftmac100_rxdes *rxdes;
>>> > + =C2=A0 struct sk_buff *skb;
>>> > + =C2=A0 struct page *page;
>>> > + =C2=A0 dma_addr_t map;
>>> > + =C2=A0 int length;
>>> > +
>>> > + =C2=A0 rxdes =3D ftmac100_rx_locate_first_segment(priv);
>>> > + =C2=A0 if (!rxdes)
>>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return false;
>>> > +
>>> > + =C2=A0 if (unlikely(ftmac100_rx_packet_error(priv, rxdes))) {
>>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ftmac100_rx_drop_packet(priv=
);
>>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return true;
>>> > + =C2=A0 }
>>> > +
>>> > + =C2=A0 /*
>>> > + =C2=A0 =C2=A0* It is impossible to get multi-segment packets
>>> > + =C2=A0 =C2=A0* because we always provide big enough receive buf=
fers.
>>> > + =C2=A0 =C2=A0*/
>>> > + =C2=A0 if (unlikely(!ftmac100_rxdes_last_segment(rxdes)))
>>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 BUG();
>>> > +
>>> > + =C2=A0 /* start processing */
>>> > + =C2=A0 skb =3D netdev_alloc_skb_ip_align(netdev, ETH_HLEN);
>>>
>>> Oh I see... You should allocate a bigger head (say... 128 bytes)
>>>
>>> And copy in it up to 128 bytes of first part... this to avoid upper
>>> stack to reallocate skb head (because IP/TCP processing need to get
>>> their headers in skb head)
>>
>> Take a look at drivers/net/niu.c :
>>
>> #define RX_SKB_ALLOC_SIZE =C2=A0 128 + NET_IP_ALIGN
>>
>> static int niu_process_rx_pkt(...)
>> {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0...
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0skb =3D netdev_alloc_skb(np->dev, RX_SKB_=
ALLOC_SIZE);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0...
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0while (1) {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0...
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0niu_rx_skb_ap=
pend(skb, page, off, append_size);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>> }
>
> Oh I got it.
>
> I will try this and redo the benchmarking.

It's a little faster than v5 now. Thanks.
I will submit the current version later.

One more question just curious, why 128 bytes?

best regards,
Po-Yu Chuang
