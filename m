From: Mike Sinkovsky <msink@permonline.ru>
Subject: Re: [PATCH v5 2/2] Ethernet driver for the WIZnet W5100 chip
Date: Sat, 31 Mar 2012 15:52:37 +0600
Message-ID: <4F76D3E5.6050605@permonline.ru>
References: <1332752876-1650-1-git-send-email-msink@permonline.ru> <1333090806-27988-2-git-send-email-msink@permonline.ru> <1333099431.19659.15.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1333099431.19659.15.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

30.03.2012 15:23, Eric Dumazet =D0=BD=D0=B0=D0=BF=D0=B8=D1=81=D0=B0=D0=BB=
:

>> +static int w5100_start_tx(struct sk_buff *skb, struct net_device *n=
dev)
>> +{
>> +	struct w5100_priv *priv =3D netdev_priv(ndev);
>> +	u16 offset;
>> +
>> +	if (w5100_read16(priv, W5100_S0_TX_FSR)<  skb->len) {
>
> There is a race here.
> Interrupt came come right here before you set the stop_queue()
>
>> +		netif_stop_queue(ndev);
>
> So Here I suggest adding a test again
> =09
> 	if (w5100_read16(priv, W5100_S0_TX_FSR)>=3D skb->len)
> 		netif_wake_queue(ndev);
> 	else
> 		return NETDEV_TX_BUSY;
>
>> +		return NETDEV_TX_BUSY;

Maybe, but I cannot test this, sorry - when I set breakpoint on this=20
branch - it never triggered, on all my tests on all boards.
Appears that my processor is too slow and cannot feed packets fast enou=
gh.

But will do, maybe it triggers for someone on fastest processors.

--=20
Mike
