From: Po-Yu Chuang <ratbert.chuang@gmail.com>
Subject: Re: [PATCH v6] net: add Faraday FTMAC100 10/100 Ethernet driver
Date: Tue, 1 Mar 2011 13:20:04 +0800
Message-ID: <AANLkTimeDR27Q7fcBmB0ix7Q_pRT_GDpc7S3LO21-fh-@mail.gmail.com>
References: <1298539762-2242-1-git-send-email-ratbert.chuang@gmail.com>
 <1298627845-1583-1-git-send-email-ratbert.chuang@gmail.com> <1298634040.2659.32.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	bhutchings@solarflare.com, joe@perches.com, dilinger@queued.net,
	mirqus@gmail.com, davem@davemloft.net,
	Po-Yu Chuang <ratbert@faraday-tech.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1298634040.2659.32.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Eric,

On Fri, Feb 25, 2011 at 7:40 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le vendredi 25 f=C3=A9vrier 2011 =C3=A0 17:57 +0800, Po-Yu Chuang a =C3=
=A9crit :
>> From: Po-Yu Chuang <ratbert@faraday-tech.com>
>>
>> FTMAC100 Ethernet Media Access Controller supports 10/100 Mbps and
>> MII. =C2=A0This driver has been working on some ARM/NDS32 SoC's incl=
uding
>> Faraday A320 and Andes AG101.
>>
>> Signed-off-by: Po-Yu Chuang <ratbert@faraday-tech.com>
>
> It seems fine to me, but I have somes questions
>
> 1) On V5, the receive function ftmac100_rx_packet() was able to proce=
ss
> several segments per skb. On V6 you process one frag only.
>
> Isnt this NIC able to handle large MTU (say... 9000) ?

No, it isn't. Its max supported packet size is 0x7ff (2047 bytes).

I wasn't sure when will get multi-segment packet. After confirmed with
HW designer two weeks ago, he told me that only if the rx buffer descri=
bed
by the first descriptor is not big enough, another rx buffer will be us=
ed.

That means, since every rx buffer is large enough, it is impossible to
get a multi-segment packets.

So I simplified ftmac100_rx_packet().

>
> 2) ftmac100_alloc_rx_page() is called and allocate a full page for a
> rxdes.
>
> 128*4K -> 512 Kbytes of memory for RX ring
>
> In V5, you were using half pages only, so 256 kbytes of memory.
>
> If you look at other drivers (NIU, BENET), they are able to use exact=
ly
> 128*2 kbytes (for a rxring of 128 slots, and 2Kbytes per slot)

Both NIU and BENET refill rx ring after all packets receive work done,
but I allocate rx buffer right after a packet is received. I think it
is difficult
to use a page for two rx buffers in my driver now. Can we just keep it
the way it is? I can study how to achieve that after current driver is =
accepted.

best regards,
Po-Yu Chuang
