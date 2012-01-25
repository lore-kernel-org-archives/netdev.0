From: "Pradeep A. Dalvi" <netdev@pradeepdalvi.com>
Subject: Re: [PATCH net] amd/lance.c: dev_alloc_skb to netdev_alloc_skb
Date: Thu, 26 Jan 2012 01:31:45 +0530
Message-ID: <CA+Dx6Ha4dnqnkR_Pc+dFZ+Ef_mxRNN_Jk44vJ_R0viuHd0JGHw@mail.gmail.com>
References: <1327517188-14088-1-git-send-email-netdev@pradeepdalvi.com>
	<1327517706.2605.7.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1327517706.2605.7.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 26, 2012 at 12:25 AM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> Le jeudi 26 janvier 2012 =E0 00:16 +0530, Pradeep A. Dalvi a =E9crit =
:
>> Replaced deprecating dev_alloc_skb with netdev_alloc_skb for amd/lan=
ce.c
>> =A0 - Removed extra skb->dev =3D dev
>>
>> Signed-off-by: Pradeep A. Dalvi <netdev@pradeepdalvi.com>
>> ---
>> =A0drivers/net/ethernet/amd/lance.c | =A0 =A09 ++++-----
>> =A01 files changed, 4 insertions(+), 5 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/amd/lance.c b/drivers/net/ethernet=
/amd/lance.c
>> index a6e2e84..a8a6b45 100644
>> --- a/drivers/net/ethernet/amd/lance.c
>> +++ b/drivers/net/ethernet/amd/lance.c
>> @@ -871,12 +871,11 @@ lance_init_ring(struct net_device *dev, gfp_t =
gfp)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct sk_buff *skb;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 void *rx_buff;
>>
>> - =A0 =A0 =A0 =A0 =A0 =A0 skb =3D alloc_skb(PKT_BUF_SZ, GFP_DMA | gf=
p);
>> + =A0 =A0 =A0 =A0 =A0 =A0 skb =3D __netdev_alloc_skb(dev, PKT_BUF_SZ=
, GFP_DMA | gfp);
>
> Nack
>
> As I already explained, alloc_skb() and netdev_alloc_skb() are
> different.
>
> Why do you repost this ?
>
> nedev_alloc_skb() adds NET_SKB_PAD bytes.
>
> This driver doesnt need this extra space.
>
> (In fact it could use kmalloc(), since the skb themselves are not use=
d
> at all : At RX time, we perform a copybreak)

Thanks Eric! Even if we try to skip NET_SKB_PAD i.e. max of 32 or
L1_CACHE_BYTES, SKB_DATA_ALIGN is anyway going to add some additional
bytes for the same reason.

And towards the end, as from my current understanding regarding skb
allocations, for MTU including alignments < 2048, there is not much to
worry about. As long as, it doesn't cross the boundary.

(And in fact, this driver doesn't even get compiled with current
configs, even after forcefully adding CONFIG_ISA & CONFIG_LANCE, of
course along with CONFIG_ISA_DMA_API. Had to change the Makefile)
