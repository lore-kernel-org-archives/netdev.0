From: "Pradeep A. Dalvi" <netdev@pradeepdalvi.com>
Subject: Re: [PATCH 1/1] netdev/ethernet: dev_alloc_skb to netdev_alloc_skb
Date: Sat, 21 Jan 2012 22:16:06 +0530
Message-ID: <CA+Dx6HbdHV9qHksqb0oH-zhYdJCm6Tu8btwG1Zs5ty1CPXXckA@mail.gmail.com>
References: <1327156996-12505-1-git-send-email-netdev@pradeepdalvi.com>
	<1327161238.2574.3.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Christoph Hellwig <hch@lst.de>, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1327161238.2574.3.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 21, 2012 at 9:23 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le samedi 21 janvier 2012 =E0 20:13 +0530, Pradeep A. Dalvi a =E9crit=
 :
>> Replaced deprecating dev_alloc_skb with netdev_alloc_skb in drivers/=
net/ethernet
>>
>> Signed-off-by: Pradeep A. Dalvi <netdev@pradeepdalvi.com>
>> ---
>
> ...
>
>> =A0114 files changed, 257 insertions(+), 203 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/3com/3c501.c b/drivers/net/etherne=
t/3com/3c501.c
>> index 68da81d..9ebc739 100644
>> --- a/drivers/net/ethernet/3com/3c501.c
>> +++ b/drivers/net/ethernet/3com/3c501.c
>> @@ -702,7 +702,7 @@ static void el_receive(struct net_device *dev)
>> =A0 =A0 =A0 =A0*/
>>
>> =A0 =A0 =A0 outb(AX_SYS, AX_CMD);
>> - =A0 =A0 skb =3D dev_alloc_skb(pkt_len+2);
>> + =A0 =A0 skb =3D netdev_alloc_skb(dev, pkt_len + NET_IP_ALIGN);
>>
>> =A0 =A0 =A0 /*
>> =A0 =A0 =A0 =A0* =A0 =A0 =A0Start of frame
>> diff --git a/drivers/net/ethernet/3com/3c509.c b/drivers/net/etherne=
t/3com/3c509.c
>
>
> So the very first chunk of this huge patch is wrong, since it adds a
> true bug. =A0(You dont change the skb_reserve(skb, 2); later)
>
> I stopped my review at this first chunk.

Thanks! I shall update skb_reserve too.

> Please dont add NET_IP_ALIGN on drivers if you cant test the change
> yourself.
>
> Some hardware really need the hardcoded 2 value.

I appreciate your concerns. Although I feel, it is essential to add
relevant comments by respective (corporate/paid :-) developers, if
their hardware needs hardcoded 2. And especially, if their expectation
is to buy their hardware, even for the smaller purpose of having
uniform mechanism. Long live Open Source! :-)
