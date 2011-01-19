From: Po-Yu Chuang <ratbert.chuang@gmail.com>
Subject: Re: [PATCH v2] net: add Faraday FTMAC100 10/100 Ethernet driver
Date: Wed, 19 Jan 2011 17:20:38 +0800
Message-ID: <AANLkTikDkvcDhjEpVL+VK=UTHb5M19Mw167R_z0QwDVW@mail.gmail.com>
References: <1294919372-1904-1-git-send-email-ratbert.chuang@gmail.com>
 <1295256060-2091-1-git-send-email-ratbert.chuang@gmail.com> <1295288462.3335.55.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ratbert@faraday-tech.com, bhutchings@solarflare.com,
	joe@perches.com, dilinger@queued.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1295288462.3335.55.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dear Eric,

On Tue, Jan 18, 2011 at 2:21 AM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le lundi 17 janvier 2011 =C3=A0 17:21 +0800, Po-Yu Chuang a =C3=A9cri=
t :
>> + =C2=A0 =C2=A0 spin_lock_irqsave(&priv->tx_lock, flags);
>> + =C2=A0 =C2=A0 ftmac100_txdes_set_skb(txdes, skb);
>> + =C2=A0 =C2=A0 ftmac100_txdes_set_dma_addr(txdes, map);
>> +
>> + =C2=A0 =C2=A0 ftmac100_txdes_set_first_segment(txdes);
>> + =C2=A0 =C2=A0 ftmac100_txdes_set_last_segment(txdes);
>> + =C2=A0 =C2=A0 ftmac100_txdes_set_txint(txdes);
>> + =C2=A0 =C2=A0 ftmac100_txdes_set_buffer_size(txdes, len);
>
> I wonder if its not too expensive to read/modify/write txdes->txdes1
>
> Maybe you should use a temporary u32 var and perform one final write =
on
> txdes->txdes1 (with the set_dma_own)

That's OK, the compiler combines these bits updates together and write =
once
since txdes is not volatile. (I checked the object file)
It's not expensive.

BTW, DMA_OWN bit is at txdes0

>> + =C2=A0 =C2=A0 priv->tx_pending++;
>> + =C2=A0 =C2=A0 if (priv->tx_pending =3D=3D TX_QUEUE_ENTRIES) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (net_ratelimit())
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 netdev_info(netdev, "tx queue full\n");
>> +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 netif_stop_queue(netdev)=
;
>> + =C2=A0 =C2=A0 }
>> +
>> + =C2=A0 =C2=A0 /* start transmit */
>> + =C2=A0 =C2=A0 ftmac100_txdes_set_dma_own(txdes);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0txdes->txdes1 =3D txdes1;
>
> BTW, shouldnt you use cpu_to_be32() or cpu_to_le32(), if this driver =
is
> multi platform ?

OK, but I am not sure if I use them the right way.
Please check my v3 patch later.

Thanks,
Po-Yu Chuang
